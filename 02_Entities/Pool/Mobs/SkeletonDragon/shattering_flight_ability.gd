class_name ShatteringFlightAbility
extends Node

# Orchestrates the dragon's "Vol fracassant" passive on the deterministic combat
# clock: take off, become invulnerable, fly to the enemy backline and sweep it
# left↔right from the air (attacking within a frontal-arc cone), then land and
# unleash the impact effects (MAGICAL_DAMAGE AOE, plus talent-gated golem summons).
# All timing is tick-based (driven from SkeletonDragon.process_tick) so the landing
# moment is reproducible and coop sync-safe. Aerial combat uses only existing public
# APIs (AutoAttack, Target, stat modifiers registry) — it touches no shared component.

#region Signals
signal flight_started
signal flight_landing_impact   ## ground-contact frame — skills hook this for landing effects
signal flight_landed
#endregion

#region Enums
enum Phase { IDLE, TAKING_OFF, FLY_IN, SWEEP, FLY_OUT, LANDING }
#endregion

#region Export
@export var _owner: SkeletonDragon
## Ground-contact frame as a fraction of the landing clip (0..1), scale-independent
## — same convention as EntityDesc.aa_X_release_normalized.
@export_range(0.0, 1.0, 0.01) var _landing_impact_normalized: float = 0.6

## Aerial enrage (active during the SWEEP phase only).
@export var _aerial_attack_speed_mult: float = 0.0 ## MULT on AS → 0.0 = base speed, 1.0 = x2
@export_range(0.0, 180.0, 1.0) var _frontal_arc_degrees: float = 60.0
## Downward tilt of the targeting cone — the dragon flies above and aims at the ground,
## so the cone points forward-and-down. Higher = more vertical (targets straight below).
@export_range(0.0, 90.0, 1.0) var _aim_pitch_degrees: float = 45.0

@export_group("Backline sweep")
## Altitude above the arena floor while sweeping.
@export var _fly_altitude: float = 8.0
## How far the sweep line is pulled inward from the enemy back edge.
@export var _back_inset: float = 4.0
## Half-width of the left↔right sweep along the backline (metres).
@export var _sweep_half_width: float = 8.0
## Seconds for one full left→right→left cycle (higher = slower sweep).
@export var _sweep_period: float = 6.0
## Number of extremity→extremity passes before landing (when not held by golems).
@export var _sweep_passes: int = 2
## Bulge of the arc at mid-sweep (toward the enemy back wall), in metres. Keep < _back_inset.
@export var _arc_depth: float = 2.0
## Transit speed (m/s) to/from the sweep line — travel time scales with the distance.
@export var _fly_transit_speed: float = 6.0
## Safety cap: even while held by the golems, the dragon lands after this many seconds.
@export var _max_hold_seconds: float = 20.0
#endregion

#region Private vars
var _anim: SkeletonDragonAnimationComponent

# Per-tick weight to settle the dragon back to its upright takeoff pose while landing.
const _LANDING_TURN_WEIGHT: float = 0.15
# Per-tick weight for smoothing the dragon's orientation while sweeping (lower = lazier turns).
const _FLY_TURN_WEIGHT: float = 0.1

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

# While held (Ash Brood golems alive), the sweep ignores the fixed pass count and runs until
# the tracked entities are all dead (polled each tick) or the safety cap is reached.
var _held: bool = false
var _hold_entities: Array[Entity] = []
# Enemy-backline frame (origin + lateral/back axes) captured at FLY_IN start.
var _back_frame: Transform3D
# Endpoints of the current transit (FLY_IN / FLY_OUT), eased from→to over the phase.
var _transit_from: Vector3
var _transit_to: Vector3
# Ticks for one extremity→extremity pass; sweep extremities fall on its multiples.
var _half_period_ticks: int = 1
# Set once the sweep should end; the actual landing waits for the next extremity.
var _sweep_release: bool = false
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
	# Fresh flight: clear any stale hold (the gold talent re-arms it on flight_started).
	_held = false
	_hold_entities.clear()
	_takeoff_yaw = _owner.rotation.y
	_takeoff_position = _owner.global_position
	_set_combat_active(false)
	_anim.begin_takeoff()
	_enter_phase(Phase.TAKING_OFF, _to_ticks(_anim.takeoff_length()))
	flight_started.emit()
	AudioManager.play_3d("dragon_wings_flapping", _owner.global_position)
	AudioManager.play_3d("dragon_roar_01", _owner.global_position)


## Called by the Ash Brood gold talent with its freshly-spawned golems: the dragon keeps
## sweeping the enemy backline (no fixed timer) until every tracked entity is dead.
func hold_flight_for(entities: Array[Entity]) -> void:
	_hold_entities = entities.duplicate()
	_held = not _hold_entities.is_empty()


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
				_begin_fly_in()
		Phase.FLY_IN:
			_advance_transit()
			if _ticks >= _phase_ticks:
				_begin_sweep()
		Phase.SWEEP:
			_advance_sweep()
			_maintain_aerial_target()
			_update_sweep_exit()
		Phase.FLY_OUT:
			_advance_transit()
			if _ticks >= _phase_ticks:
				_begin_landing()
		Phase.LANDING:
			_settle_to_upright()
			if not _impact_done and _ticks >= _impact_tick:
				_impact_done = true
				# Ground contact: become a normal unit again right away so enemies
				# re-acquire and re-attack without waiting for the landing clip to end.
				_owner.alterations.cancel_state(Alteration.Type.INVULNERABLE)
				_owner.alterations.cancel_state(Alteration.Type.UNTARGETABLE)
				flight_landing_impact.emit()
			if _ticks >= _phase_ticks:
				_finish_flight()
#endregion

#region Private functions
func _begin_fly_in() -> void:
	_anim.enter_fly_loop()
	_anim.set_fly_dir_forward()
	_back_frame = _compute_back_frame()
	_half_period_ticks = _to_ticks(_sweep_period / 2.0)
	_transit_from = _owner.global_position
	_transit_to = _sweep_point(0) # phase 0 → the entry extremity of the sweep
	_enter_phase(Phase.FLY_IN, _travel_ticks(_transit_from, _transit_to))


func _begin_sweep() -> void:
	_anim.set_fly_dir_hover()
	_enable_aerial_combat()
	_sweep_release = false
	_enter_phase(Phase.SWEEP, _sweep_passes * _half_period_ticks)


func _begin_fly_out() -> void:
	_disable_aerial_combat()
	if _owner.auto_attack != null:
		_owner.auto_attack.set_paused(true) # no attacks during the retreat
	_anim.set_fly_dir_forward() # flies home nose-first (home lies past the enemies from the backline)
	_transit_from = _owner.global_position
	_transit_to = _takeoff_position + Vector3.UP * _fly_altitude
	_enter_phase(Phase.FLY_OUT, _travel_ticks(_transit_from, _transit_to))


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


# Polled each FLYING tick: true once every held entity is gone (freed or dead).
func _hold_entities_all_dead() -> bool:
	for e: Entity in _hold_entities:
		if is_instance_valid(e) and not e.is_dead():
			return false
	return true


# FLY_IN / FLY_OUT: ease the dragon along a straight line between the transit endpoints at a
# distance-scaled pace (smoothstep = soft start/stop), always flying nose-first toward the
# destination (forward clip). The single ~180° wheel-around happens at the FLY_IN→SWEEP handoff.
func _advance_transit() -> void:
	var r: float = smoothstep(0.0, 1.0, float(_ticks) / float(_phase_ticks))
	_owner.global_position = _transit_from.lerp(_transit_to, r)
	_face_heading(_transit_to - _transit_from)


# Semi-stationary sweep over the enemy backline, facing the arena. Position is a pure function
# of the tick (deterministic). Extremities (lateral velocity ≈ 0) land on _half_period_ticks.
func _advance_sweep() -> void:
	_owner.global_position = _sweep_point(_ticks)
	_face_heading(-_back_frame.basis.z)


# Sweep position at a given tick: lateral cosine wave across the backline (tick 0 = an
# extremity), bowing toward the back wall at mid-pass and flattening at the extremities.
func _sweep_point(ticks: int) -> Vector3:
	var phase: float = PI * float(ticks) / float(_half_period_ticks)
	var lateral: float = cos(phase) * _sweep_half_width
	var bulge: float = _arc_depth * sin(phase) * sin(phase)
	return _back_frame.origin + _back_frame.basis.x * lateral + _back_frame.basis.z * bulge


# End the sweep when the pass count is reached (or the golem hold is released), then hand off
# to FLY_OUT on the next extremity, where the lateral motion is momentarily still.
func _update_sweep_exit() -> void:
	if not _sweep_release:
		if _held:
			if _ticks >= _to_ticks(_max_hold_seconds) or _hold_entities_all_dead():
				_held = false
				_sweep_release = true
		elif _ticks >= _phase_ticks:
			_sweep_release = true
	if _sweep_release and _ticks % _half_period_ticks == 0:
		_begin_fly_out()


func _travel_ticks(from: Vector3, to: Vector3) -> int:
	return _to_ticks(from.distance_to(to) / maxf(0.1, _fly_transit_speed))


# Slerp the body to face a horizontal heading (-Z toward it), kept level. Banking is off for
# now (re-introduce here, proportional to lateral acceleration, once the feel is locked).
func _face_heading(heading: Vector3) -> void:
	var h: Vector3 = heading
	h.y = 0.0
	if h.length_squared() < 0.0001:
		return
	h = h.normalized()
	var desired: Basis = Transform3D(Basis(), Vector3.ZERO).looking_at(h, Vector3.UP).basis
	_owner.global_transform.basis = _owner.global_transform.basis.orthonormalized().slerp(desired, _FLY_TURN_WEIGHT)


# Enemy-backline frame at flight altitude, from the arena geometry. Falls back to a frame
# ahead of the takeoff pose when no arena info is available.
func _compute_back_frame() -> Transform3D:
	var ctx: EntityContext = _owner.get_context()
	var azm: ArenaZoneManager = ctx.arena_zone_manager if ctx != null else null
	if azm != null:
		return azm.get_enemy_back_frame(_owner.team, _back_inset, _fly_altitude)
	var fwd: Vector3 = -(Basis(Vector3.UP, _takeoff_yaw).z)
	var origin: Vector3 = _takeoff_position + Vector3.UP * _fly_altitude
	# basis.z = -fwd so -basis.z = fwd → the arc bulges forward, like the arena frame.
	return Transform3D(Basis(fwd.cross(Vector3.UP).normalized(), Vector3.UP, -fwd), origin)


# Per-tick blend of the whole orientation back to the upright takeoff facing during landing
# (the flight leaves the dragon pitched/banked; settle it before ground contact).
func _settle_to_upright() -> void:
	var t: Transform3D = _owner.global_transform
	t.basis = t.basis.orthonormalized().slerp(Basis(Vector3.UP, _takeoff_yaw), _LANDING_TURN_WEIGHT)
	# Glide back to the takeoff spot while landing, so the dragon "comes home" from the backline.
	t.origin = t.origin.lerp(_takeoff_position, _LANDING_TURN_WEIGHT)
	_owner.global_transform = t


# Toggles the "whole flight" state (takeoff → land/abort), active=false on takeoff,
# active=true on land/abort. While airborne the dragon is invulnerable (also prevents
# dying mid-flight, which would otherwise leave a corpse following the path); movement
# is halted so it does not fight the flight path; the auto-attack is paused — which also
# drops any in-progress swing (see AutoAttackComponent.set_paused) so no delayed hit
# lands; enemies also drop him as a target; mana regen is zeroed so the ultimate can't
# auto-cast mid-flight (stance conflict).
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
		_owner.alterations.cancel_state(Alteration.Type.UNTARGETABLE)
		_unregister_mana_cut()
	else:
		_owner.alterations.apply_state(Alteration.Type.INVULNERABLE)
		_owner.alterations.apply_state(Alteration.Type.UNTARGETABLE)
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


# Aerial enrage, active only during the SWEEP phase: unpause the auto-attack, apply the
# attack-speed + (effectively infinite) range stat modifiers, and re-pick a random
# frontal enemy on every completed attack (the "strafe" feel).
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
