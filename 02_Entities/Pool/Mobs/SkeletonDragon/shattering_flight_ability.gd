class_name ShatteringFlightAbility
extends Node

# Orchestrates the dragon's "Vol fracassant" passive on the deterministic combat
# clock: take off, become invulnerable, traverse a flight path above the arena while
# attacking from the air (aerial enrage: doubled attack speed + random frontal-arc
# targeting), then land and unleash the impact effects (MAGICAL_DAMAGE AOE, plus
# talent-gated stun / golem summons). All timing is tick-based (driven from
# SkeletonDragon.process_tick) so the landing moment is reproducible and coop
# sync-safe. Aerial combat uses only existing public APIs (AutoAttack, Target,
# stat modifiers registry) — it touches no shared component.

#region Signals
signal flight_started
signal flight_landing_impact   ## ground-contact frame — skills hook this for landing effects
signal flight_landed
#endregion

#region Enums
enum Phase { IDLE, TAKING_OFF, FLYING, LANDING }
#endregion

#region Export
@export var _owner: SkeletonDragon
## Procedural flight-path shape, generated at takeoff and flown relative to the takeoff pose.
@export var _flight_profile: FlightPathProfile
@export var _flight_duration: float = 5.0
## Fraction of the flight spent easing in/out at each end (0 = constant speed).
@export_range(0.0, 0.5, 0.01) var _ease_edge: float = 0.2
## Ground-contact frame as a fraction of the landing clip (0..1), scale-independent
## — same convention as EntityDesc.aa_X_release_normalized.
@export_range(0.0, 1.0, 0.01) var _landing_impact_normalized: float = 0.6

@export_group("Banking")
## Lean angle into turns (degrees). 0 = stays flat.
@export_range(0.0, 80.0, 1.0) var _bank_degrees: float = 40.0
## Reverse the lean partway through the flight (the dragon rolls level, then the other way).
@export var _bank_flip: bool = true
## Where the flip happens, as a fraction of the flight [0..1].
@export_range(0.0, 1.0, 0.01) var _bank_flip_at: float = 0.5
## Half-width of the smooth roll-through-level transition around the flip point.
@export_range(0.01, 0.3, 0.01) var _bank_flip_width: float = 0.08

## Aerial enrage (active during the FLYING phase only).
@export var _aerial_attack_speed_mult: float = 1.0 ## MULT on AS → 1.0 = x2 base
@export_range(0.0, 180.0, 1.0) var _frontal_arc_degrees: float = 60.0
## Downward tilt of the targeting cone — the dragon flies above and aims at the ground,
## so the cone points forward-and-down. Higher = more vertical (targets straight below).
@export_range(0.0, 90.0, 1.0) var _aim_pitch_degrees: float = 45.0
#endregion

#region Private vars
var _anim: SkeletonDragonAnimationComponent
# Curve generated from _flight_profile at takeoff, flown in the takeoff-local space.
var _curve: Curve3D
# Takeoff pose (position + facing, upright) frozen at takeoff, so the curve is flown as a
# maneuver relative to it (no feedback from moving the owner along it).
var _takeoff_origin: Transform3D

# Metres sampled ahead on the curve to orient the dragon toward its travel.
const _FACING_LOOKAHEAD: float = 3.0
# Per-tick weight to settle the dragon back to its upright takeoff pose while landing.
const _LANDING_TURN_WEIGHT: float = 0.15

const _AERIAL_AS_MOD_ID: StringName = &"AerialEnrage"
const _AERIAL_RANGE_MOD_ID: StringName = &"AerialRange"
const _AERIAL_RANGE_BONUS: float = 9999.0 # effectively infinite range → no approach in air
const _NO_MANA_REGEN_MOD_ID: StringName = &"FlightNoManaRegen"

var _takeoff_yaw: float
var _takeoff_position: Vector3
var _phase: Phase = Phase.IDLE
var _ticks: int = 0
var _phase_ticks: int = 0
var _impact_tick: int = 0
var _impact_done: bool = false

var _as_modifier: StatModifier
var _range_modifier: StatModifier
var _aerial_target_counter: int = 0
var _mana_modifier: StatModifier
#endregion

#region Node base functions
func _ready() -> void:
	if _owner == null:
		Verbose.error("ShatteringFlightAbility: no owner", Verbose.Category.ENTITY)
		return

	_anim = _owner.animation as SkeletonDragonAnimationComponent
	if _anim == null:
		Verbose.error("ShatteringFlightAbility: owner has no SkeletonDragonAnimationComponent", Verbose.Category.ENTITY)
		return

	# The flight advances on FightingManager ticks, which stop when the fight ends.
	# If that happens mid-flight we'd freeze in the air → clean up on this signal.
	_owner.fighting_state_changed.connect(_on_fighting_state_changed)
#endregion

#region Public functions
func trigger_flight() -> void:
	if _phase != Phase.IDLE:
		Verbose.warn("trigger_flight ignored: already in flight", Verbose.Category.ENTITY)
		return
	if _anim == null:
		return
	_takeoff_yaw = _owner.rotation.y
	_takeoff_position = _owner.global_position
	# Anchor the maneuver to the takeoff pose (position + facing), upright. The curve is
	# authored in this local space, so -Z forward aligns with the dragon's takeoff facing.
	_takeoff_origin = Transform3D(Basis(Vector3.UP, _takeoff_yaw), _takeoff_position)
	if _flight_profile != null:
		_curve = _flight_profile.build_curve()
	_set_combat_active(false)
	_anim.begin_takeoff()
	_enter_phase(Phase.TAKING_OFF, _to_ticks(_anim.takeoff_length()))
	flight_started.emit()


## Hard interrupt (e.g. death mid-flight): stops the sequence and restores state.
func abort_flight() -> void:
	if _phase == Phase.IDLE:
		return
	_disable_aerial_combat()
	_anim.end_fly()
	_set_combat_active(true)
	_phase = Phase.IDLE


## Driven every deterministic tick by SkeletonDragon.process_tick().
func process_tick() -> void:
	if _phase == Phase.IDLE:
		return
	_ticks += 1

	match _phase:
		Phase.TAKING_OFF:
			if _ticks >= _phase_ticks:
				_begin_flying()
		Phase.FLYING:
			_advance_flight_path()
			_maintain_aerial_target()
			if _ticks >= _phase_ticks:
				_begin_landing()
		Phase.LANDING:
			_settle_to_upright()
			if not _impact_done and _ticks >= _impact_tick:
				_impact_done = true
				flight_landing_impact.emit()
			if _ticks >= _phase_ticks:
				_finish_flight()
#endregion

#region Private functions
func _begin_flying() -> void:
	_anim.enter_fly_loop()
	_enable_aerial_combat()
	_enter_phase(Phase.FLYING, _to_ticks(_flight_duration))


func _begin_landing() -> void:
	_disable_aerial_combat()
	if _owner.auto_attack != null:
		_owner.auto_attack.set_paused(true) # no attacks during the landing transition
	_anim.begin_landing()
	var landing_ticks: int = _to_ticks(_anim.landing_length())
	_impact_tick = int(round(_landing_impact_normalized * landing_ticks))
	_impact_done = false
	_enter_phase(Phase.LANDING, landing_ticks)


func _finish_flight() -> void:
	_anim.end_fly()
	_set_combat_active(true)
	_phase = Phase.IDLE
	flight_landed.emit()


func _enter_phase(phase: Phase, duration_ticks: int) -> void:
	_phase = phase
	_ticks = 0
	_phase_ticks = maxi(1, duration_ticks)


func _to_ticks(seconds: float) -> int:
	return maxi(1, int(round(seconds * Entity.TICKS_PER_SECOND)))


func _advance_flight_path() -> void:
	if _curve == null:
		return
	var length: float = _curve.get_baked_length()
	if length <= 0.0:
		return
	var ratio: float = _eased(float(_ticks) / float(_phase_ticks))
	_owner.global_transform = _flight_pose(ratio * length, length)


# World pose along the flight curve at a baked distance: -Z follows the travel tangent
# (nose pitches with climbs/dives) and the up vector is a twist-free level frame rolled by
# the banking angle. Banking is computed from the path's horizontal turn direction rather
# than the curve's baked up-vector, whose parallel-transport flips would invert the lean.
func _flight_pose(dist: float, length: float) -> Transform3D:
	var pos: Vector3 = _sample_world(dist)
	var ahead: Vector3 = _sample_world(minf(dist + _FACING_LOOKAHEAD, length))
	var fwd: Vector3 = ahead - pos
	if fwd.length_squared() < 0.0001:
		fwd = -_owner.global_transform.basis.z
	fwd = fwd.normalized()
	return Transform3D(Basis(), pos).looking_at(pos + fwd, _banked_up(fwd, dist, length))


func _sample_world(dist: float) -> Vector3:
	return _takeoff_origin * _curve.sample_baked(dist)


func _banked_up(fwd: Vector3, dist: float, length: float) -> Vector3:
	var right: Vector3 = fwd.cross(Vector3.UP)
	if right.length_squared() < 0.00001:  # travelling near-vertical
		right = fwd.cross(Vector3.FORWARD)
	right = right.normalized()
	var level_up: Vector3 = right.cross(fwd).normalized()
	return level_up.rotated(fwd, _roll_angle(dist, length))


# Roll from the signed horizontal turn direction → constant lean on a constant-radius
# loop. The flip multiplier reverses it (smoothly, through level) past _bank_flip_at.
func _roll_angle(dist: float, length: float) -> float:
	var e: float = 0.5
	var pos: Vector3 = _sample_world(dist)
	var back: Vector3 = _sample_world(clampf(dist - e, 0.0, length))
	var front: Vector3 = _sample_world(clampf(dist + e, 0.0, length))
	var hb: Vector2 = Vector2(pos.x - back.x, pos.z - back.z)
	var hf: Vector2 = Vector2(front.x - pos.x, front.z - pos.z)
	if hb.length_squared() < 0.000001 or hf.length_squared() < 0.000001:
		return 0.0
	return -signf(hb.angle_to(hf)) * deg_to_rad(_bank_degrees) * _flip_sign(dist / length)


# +1 before the flip, -1 after, ramping smoothly through 0 across the flip window.
func _flip_sign(r: float) -> float:
	if not _bank_flip:
		return 1.0
	var w: float = maxf(0.001, _bank_flip_width)
	return 1.0 - 2.0 * smoothstep(_bank_flip_at - w, _bank_flip_at + w, r)


# Ease in/out only near the extremities, constant speed through the middle.
func _eased(r: float) -> float:
	var e: float = _ease_edge
	if e <= 0.0:
		return r
	if r < e:
		return smoothstep(0.0, 1.0, r / e) * e
	if r > 1.0 - e:
		return (1.0 - e) + smoothstep(0.0, 1.0, (r - (1.0 - e)) / e) * e
	return r


# Per-tick blend of the whole orientation back to the upright takeoff facing during landing
# (the flight leaves the dragon pitched/banked; settle it before ground contact).
func _settle_to_upright() -> void:
	var t: Transform3D = _owner.global_transform
	t.basis = t.basis.orthonormalized().slerp(Basis(Vector3.UP, _takeoff_yaw), _LANDING_TURN_WEIGHT)
	_owner.global_transform = t


# Toggles the "whole flight" state (takeoff → land/abort), active=false on takeoff,
# active=true on land/abort. While airborne the dragon is invulnerable (also prevents
# dying mid-flight, which would otherwise leave a corpse following the path); movement
# is halted so it does not fight the flight path; the auto-attack is paused — which also
# drops any in-progress swing (see AutoAttackComponent.set_paused) so no delayed hit
# lands; mana regen is zeroed so the ultimate can't auto-cast mid-flight (stance conflict).
func _set_combat_active(active: bool) -> void:
	if _owner.movement != null:
		if active:
			_owner.movement.start()
		else:
			_owner.movement.stop()
	if _owner.auto_attack != null:
		_owner.auto_attack.set_paused(not active)
	if active:
		_owner.alterations.cancel_state(Alteration.Type.INVULNERABLE)
		_unregister_mana_cut()
	else:
		_owner.alterations.apply_state(Alteration.Type.INVULNERABLE)
		_register_mana_cut()


func _register_mana_cut() -> void:
	if _owner.stat_modifiers_registry == null or _mana_modifier != null:
		return
	_mana_modifier = StatModifier.new()
	_mana_modifier.id = _NO_MANA_REGEN_MOD_ID
	_mana_modifier.stat_type = EntityStats.StatType.MANA_REGEN
	_mana_modifier.calc_type = StatModifier.CalcType.MULT
	_mana_modifier.value = -1.0 # (1 + -1) = 0 → no mana regen while airborne
	_owner.stat_modifiers_registry.register_modifier(_mana_modifier)


func _unregister_mana_cut() -> void:
	if _owner.stat_modifiers_registry == null or _mana_modifier == null:
		return
	_owner.stat_modifiers_registry.unregister_modifier(_mana_modifier)
	_mana_modifier = null


# Aerial enrage, active only during FLYING: unpause the auto-attack, apply the
# doubled attack speed + (effectively infinite) range stat modifiers, and re-pick a
# random frontal enemy on every completed attack (the "strafe" feel).
func _enable_aerial_combat() -> void:
	if _owner.auto_attack == null:
		return
	_owner.auto_attack.set_paused(false)
	_register_aerial_modifiers()
	if not _owner.auto_attack.attack_completed.is_connected(_on_aerial_attack_completed):
		_owner.auto_attack.attack_completed.connect(_on_aerial_attack_completed)
	if not _owner.auto_attack.attack_started.is_connected(_on_aerial_attack_started):
		_owner.auto_attack.attack_started.connect(_on_aerial_attack_started)
	_pick_aerial_target()


func _disable_aerial_combat() -> void:
	_unregister_aerial_modifiers()
	if _owner.auto_attack == null:
		return
	if _owner.auto_attack.attack_completed.is_connected(_on_aerial_attack_completed):
		_owner.auto_attack.attack_completed.disconnect(_on_aerial_attack_completed)
	if _owner.auto_attack.attack_started.is_connected(_on_aerial_attack_started):
		_owner.auto_attack.attack_started.disconnect(_on_aerial_attack_started)


func _register_aerial_modifiers() -> void:
	if _owner.stat_modifiers_registry == null:
		return
	_as_modifier = StatModifier.new()
	_as_modifier.id = _AERIAL_AS_MOD_ID
	_as_modifier.stat_type = EntityStats.StatType.AS
	_as_modifier.calc_type = StatModifier.CalcType.MULT
	_as_modifier.value = _aerial_attack_speed_mult
	_owner.stat_modifiers_registry.register_modifier(_as_modifier)

	_range_modifier = StatModifier.new()
	_range_modifier.id = _AERIAL_RANGE_MOD_ID
	_range_modifier.stat_type = EntityStats.StatType.AR
	_range_modifier.calc_type = StatModifier.CalcType.ADD
	_range_modifier.value = _AERIAL_RANGE_BONUS
	_owner.stat_modifiers_registry.register_modifier(_range_modifier)


func _unregister_aerial_modifiers() -> void:
	if _owner.stat_modifiers_registry == null:
		return
	if _as_modifier != null:
		_owner.stat_modifiers_registry.unregister_modifier(_as_modifier)
		_as_modifier = null
	if _range_modifier != null:
		_owner.stat_modifiers_registry.unregister_modifier(_range_modifier)
		_range_modifier = null


func _pick_aerial_target() -> void:
	var target: Entity = _pick_random_frontal_enemy()
	if target != null:
		_owner.auto_attack.set_target(target)


# Re-acquire a frontal target when the auto-attack has none — its target died, left
# the fight, or became untargetable. Without this the dragon stays idle for the rest
# of the flight (re-targeting otherwise only happens on attack_completed, which never
# fires while idle).
func _maintain_aerial_target() -> void:
	if _owner.auto_attack == null:
		return
	if not is_instance_valid(_owner.auto_attack.get_current_target()):
		_pick_aerial_target()


# Random enemy within the frontal arc of the dragon's flight facing, so attacking it
# never forces an impossible body turn (the body stays oriented along the path).
# Uses the seeded RNG (battle_id) → deterministic / coop sync-safe.
func _pick_random_frontal_enemy() -> Entity:
	if _owner.target == null:
		return null
	# Aim direction: the flight's horizontal heading tilted downward, so the cone
	# covers enemies in front AND below the airborne dragon (3D angle, not flattened).
	var heading: Vector3 = -_owner.global_transform.basis.z
	heading.y = 0.0
	if heading.length_squared() < 0.0001:
		return null
	heading = heading.normalized()
	var pitch: float = deg_to_rad(_aim_pitch_degrees)
	var aim: Vector3 = (heading * cos(pitch) + Vector3.DOWN * sin(pitch)).normalized()

	var candidates: Array[Entity] = []
	for enemy: Entity in _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
		if not is_instance_valid(enemy):
			continue
		var to_enemy: Vector3 = enemy.global_position - _owner.global_position
		if to_enemy.length_squared() < 0.01:
			continue
		if rad_to_deg(aim.angle_to(to_enemy)) <= _frontal_arc_degrees:
			candidates.append(enemy)
	_aerial_target_counter += 1
	return Utils.pick_random(candidates, _owner.battle_id, "aerial_target_" + str(_aerial_target_counter))


func _on_aerial_attack_completed() -> void:
	_pick_aerial_target()


# The ground attack anim is blocked by _lock_animation while flying; play the dedicated
# fly-attack one-shot instead so the dragon visibly attacks in the air.
func _on_aerial_attack_started(_lock_seconds: float) -> void:
	_anim.play_fly_attack()


func _on_fighting_state_changed(new_state: Entity.FightingState) -> void:
	if _phase == Phase.IDLE or new_state == Entity.FightingState.FIGHTING:
		return
	# Fight ended mid-flight: ticks stop, so abort now and drop the dragon back to its
	# upright takeoff pose instead of leaving it frozen, pitched and banked, in the air.
	abort_flight()
	_owner.global_transform = Transform3D(Basis(Vector3.UP, _takeoff_yaw), _takeoff_position)
#endregion
