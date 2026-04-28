class_name SpawnAnimationComponent
extends EntityComponent

# Plays the entity's spawn animation (visual scale-up tween) and signals when
# the entity is ready to leave the SPAWNING state. Timing is tick-based for
# determinism; the visual tween runs in parallel and is purely cosmetic.

#region ============================== Signals ==============================
signal spawn_finished
#endregion

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
#endregion

#region ============================== Export ==============================
@export var duration: float = 0.5
@export var skip_animation: bool = false
#endregion

#region ============================== Private variables ==============================
var _ticks_remaining: int = -1
var _tween: Tween
#endregion

#region ============================== Public functions ==============================
func start_spawn() -> void:
	if skip_animation:
		spawn_finished.emit()
		return

	if _owner == null or _owner._visual_3d == null:
		Verbose.warn("SpawnAnimationComponent has no visual to animate, skipping", Verbose.Category.ENTITY)
		spawn_finished.emit()
		return

	_ticks_remaining = int(duration * TICKS_PER_SECOND)
	_play_visual_animation()


func process_tick() -> void:
	if _ticks_remaining > 0:
		_ticks_remaining -= 1
		if _ticks_remaining == 0:
			spawn_finished.emit()
#endregion

#region ============================== Private functions ==============================
func _play_visual_animation() -> void:
	var visual: Node3D = _owner._visual_3d
	visual.scale = Vector3.ZERO
	var target_scale: float = _owner.stats.scale
	_tween = _owner.create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(visual, "scale", Vector3(target_scale, target_scale, target_scale), duration)
#endregion
