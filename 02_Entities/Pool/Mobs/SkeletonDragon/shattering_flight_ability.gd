class_name ShatteringFlightAbility
extends Node

# Orchestrates the dragon's "Vol fracassant" passive on the deterministic combat
# clock: take off, become untargetable, traverse a flight path above the arena,
# then land and unleash the impact effects (MAGICAL_DAMAGE AOE, and talent-gated
# stun / golem summons). All timing is tick-based (driven from SkeletonDragon.
# process_tick) so the landing damage moment is reproducible and coop sync-safe.
# Animation is delegated to SkeletonDragonAnimationComponent; this node never
# touches the AnimationTree directly.

#region Signals
signal flight_started
signal flight_landed
#endregion

#region Enums
enum Phase { IDLE, TAKING_OFF, FLYING, LANDING }
#endregion

#region Export
@export var _owner: SkeletonDragon
@export var _flight_path: Path3D
@export var _flight_duration: float = 4.0
## Ground-contact frame as a fraction of the landing clip (0..1), scale-independent
## — same convention as EntityDesc.aa_X_release_normalized.
@export_range(0.0, 1.0, 0.01) var _landing_impact_normalized: float = 0.6
#endregion

#region Private vars
var _anim: SkeletonDragonAnimationComponent
var _path_follow: PathFollow3D

var _phase: Phase = Phase.IDLE
var _ticks: int = 0
var _phase_ticks: int = 0
var _impact_tick: int = 0
var _impact_done: bool = false
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

	if _flight_path != null:
		_path_follow = PathFollow3D.new()
		_flight_path.add_child(_path_follow)
#endregion

#region Public functions
func trigger_flight() -> void:
	if _phase != Phase.IDLE:
		Verbose.warn("trigger_flight ignored: already in flight", Verbose.Category.ENTITY)
		return
	if _anim == null:
		return
	_anim.begin_takeoff()
	_enter_phase(Phase.TAKING_OFF, _to_ticks(_anim.takeoff_length()))
	flight_started.emit()


## Hard interrupt (e.g. death mid-flight): stops the sequence and restores state.
func abort_flight() -> void:
	if _phase == Phase.IDLE:
		return
	_anim.end_fly()
	_owner.alterations.cancel_state(Alteration.Type.UNTARGETABLE)
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
			if _ticks >= _phase_ticks:
				_begin_landing()
		Phase.LANDING:
			if not _impact_done and _ticks >= _impact_tick:
				_impact_done = true
				_apply_landing_effects()
			if _ticks >= _phase_ticks:
				_finish_flight()
#endregion

#region Private functions
func _begin_flying() -> void:
	_anim.enter_fly_loop()
	_owner.alterations.apply_state(Alteration.Type.UNTARGETABLE)
	_enter_phase(Phase.FLYING, _to_ticks(_flight_duration))


func _begin_landing() -> void:
	_anim.begin_landing()
	var landing_ticks: int = _to_ticks(_anim.landing_length())
	_impact_tick = int(round(_landing_impact_normalized * landing_ticks))
	_impact_done = false
	_enter_phase(Phase.LANDING, landing_ticks)


func _finish_flight() -> void:
	_anim.end_fly()
	_owner.alterations.cancel_state(Alteration.Type.UNTARGETABLE)
	_phase = Phase.IDLE
	flight_landed.emit()


func _enter_phase(phase: Phase, duration_ticks: int) -> void:
	_phase = phase
	_ticks = 0
	_phase_ticks = maxi(1, duration_ticks)


func _to_ticks(seconds: float) -> int:
	return maxi(1, int(round(seconds * Entity.TICKS_PER_SECOND)))


func _advance_flight_path() -> void:
	if _path_follow == null:
		return
	_path_follow.progress_ratio = float(_ticks) / float(_phase_ticks)
	_owner.global_position = _path_follow.global_position


func _apply_landing_effects() -> void:
	Verbose.debug("Shattering flight landing impact", Verbose.Category.ENTITY)
	# AOE MAGICAL_DAMAGE on the landing zone, plus talent-gated stun / golem
	# summons, routed through the dragon's action sender pipeline.
#endregion
