class_name DevastatingBreathAbility
extends Node

# Orchestrates the dragon's "Souffle dévastateur" ultimate on the deterministic combat
# clock: a 3-phase spell (Combat_Ground_Spell_Start → _Spell loop → _Spell_End). During
# the CHANNEL phase the breath is on and the dragon rotates in place so the head-mounted
# flame sweeps the arena: it first turns _anticipation_degrees to a random side, then
# sweeps _sweep_degrees the other way (constant angular speed over _channel_duration).
# Movement + auto-attack are suspended while channeling (not invulnerable). The damage
# (Ignite DoT to enemies entering the breath) is owned by SE_DevastatingBreath via the
# BreathVfxController signals — this node only drives the sweep, the anim and the VFX.

#region Signals
signal channel_started
signal channel_ended
#endregion

#region Enums
enum Phase { IDLE, WINDUP, CHANNEL, RECOVERY }
#endregion

#region Export
@export var _owner: SkeletonDragon
@export var _channel_duration: float = 4.0
@export_range(0.0, 90.0, 1.0) var _anticipation_degrees: float = 30.0
@export_range(0.0, 180.0, 1.0) var _sweep_degrees: float = 120.0
#endregion

#region Private vars
var _anim: SkeletonDragonAnimationComponent
var _breath: BreathVfxController

var _phase: Phase = Phase.IDLE
var _ticks: int = 0
var _phase_ticks: int = 0

var _start_yaw: float
var _sweep_dir: float = 1.0 # +1 / -1, the side the anticipation turn goes
var _cast_counter: int = 0
#endregion

#region Node base functions
func _ready() -> void:
	if _owner == null:
		Verbose.error("DevastatingBreathAbility: no owner", Verbose.Category.ENTITY)
		return
	_anim = _owner.animation as SkeletonDragonAnimationComponent
	if _anim == null:
		Verbose.error("DevastatingBreathAbility: owner has no SkeletonDragonAnimationComponent", Verbose.Category.ENTITY)
		return
	_breath = _owner.get_breath_controller()

	# Ticks stop when the fight ends — clean up if that happens mid-channel.
	_owner.fighting_state_changed.connect(_on_fighting_state_changed)
#endregion

#region Public functions
func trigger() -> void:
	if _phase != Phase.IDLE:
		Verbose.warn("DevastatingBreath trigger ignored: already channeling", Verbose.Category.ENTITY)
		return
	if _anim == null:
		return
	_start_yaw = _owner.rotation.y
	_cast_counter += 1
	_sweep_dir = Utils.pick_random([-1.0, 1.0], _owner.battle_id, "breath_sweep_" + str(_cast_counter))
	# Lock the animation first so movement.stop() below can't flip switch_main via the
	# base is_moving callback before we hand control to the spell stance.
	_anim.begin_spell()
	_set_combat_active(false)
	_enter_phase(Phase.WINDUP, _to_ticks(_anim.spell_start_length()))


## Hard interrupt (e.g. death mid-channel): stops the spell and restores state.
func abort() -> void:
	if _phase == Phase.IDLE:
		return
	if _breath != null:
		_breath.set_breath_active(false)
	_anim.finish_spell()
	_set_combat_active(true)
	_phase = Phase.IDLE


## Driven every deterministic tick by SkeletonDragon.process_tick().
func process_tick() -> void:
	if _phase == Phase.IDLE:
		return
	_ticks += 1

	match _phase:
		Phase.WINDUP:
			if _ticks >= _phase_ticks:
				_begin_channel()
		Phase.CHANNEL:
			_update_sweep()
			if _ticks >= _phase_ticks:
				_begin_recovery()
		Phase.RECOVERY:
			if _ticks >= _phase_ticks:
				_finish()
#endregion

#region Private functions
func _begin_channel() -> void:
	_anim.channel_spell()
	if _breath != null:
		_breath.set_breath_active(true)
	AudioManager.play_3d("dragon_firebreath", _owner.global_position)
	channel_started.emit()
	_enter_phase(Phase.CHANNEL, _to_ticks(_channel_duration))


func _begin_recovery() -> void:
	if _breath != null:
		_breath.set_breath_active(false)
	channel_ended.emit()
	_anim.end_spell()
	_enter_phase(Phase.RECOVERY, _to_ticks(_anim.spell_end_length()))


func _finish() -> void:
	_anim.finish_spell()
	_set_combat_active(true)
	_phase = Phase.IDLE


# Rotate the dragon so the head-mounted breath sweeps. Constant angular speed over the
# whole channel: turn _anticipation_degrees to _sweep_dir, then reverse and travel
# _sweep_degrees the other way. So the flame covers an arc offset from the cast facing.
func _update_sweep() -> void:
	var total_travel: float = _anticipation_degrees + _sweep_degrees
	var traveled: float = (float(_ticks) / float(_phase_ticks)) * total_travel
	var offset_deg: float
	if traveled <= _anticipation_degrees:
		offset_deg = _sweep_dir * traveled
	else:
		offset_deg = _sweep_dir * (2.0 * _anticipation_degrees - traveled)
	_owner.rotation.y = _start_yaw + deg_to_rad(offset_deg)


# Suspends/resumes movement + auto-attack for the channel (not invulnerable). Pausing
# the auto-attack also drops any in-progress swing (see AutoAttackComponent.set_paused).
func _set_combat_active(active: bool) -> void:
	if _owner.movement != null:
		if active:
			_owner.movement.start()
		else:
			_owner.movement.stop()
	if _owner.auto_attack != null:
		_owner.auto_attack.set_paused(not active)


func _enter_phase(phase: Phase, duration_ticks: int) -> void:
	_phase = phase
	_ticks = 0
	_phase_ticks = maxi(1, duration_ticks)


func _to_ticks(seconds: float) -> int:
	return maxi(1, int(round(seconds * Entity.TICKS_PER_SECOND)))
#endregion

#region Callbacks
func _on_fighting_state_changed(new_state: Entity.FightingState) -> void:
	if _phase == Phase.IDLE or new_state == Entity.FightingState.FIGHTING:
		return
	abort()
#endregion
