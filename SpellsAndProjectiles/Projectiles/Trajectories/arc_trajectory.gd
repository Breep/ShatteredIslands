class_name ArcTrajectory
extends ProjectileTrajectory

## Arc trajectory that follows a parabolic path using sinusoidal height.
## The projectile reaches peak height at the midpoint of travel.

@export var arc_height: float = 2.0           # Maximum height of the arc
@export var randomize_by: float = 0.5         # ± randomness on arc height
@export var vertical_offset: float = 1.0      # Height offset from target

var _travel_time: float
var _target_snapshot: Vector3
var _height_variation: float


func _on_init() -> void:
	_target_snapshot = _target.get_collision_center()
	var distance := _start_pos.distance_to(_target_snapshot)
	_travel_time = max(0.001, distance / max(0.001, speed))
	_height_variation = randf_range(-randomize_by, randomize_by)


func update(delta: float) -> void:
	_t = min(1.0, _t + delta / _travel_time)
	
	# Interpolate along straight line
	var base := _start_pos.lerp(_target_snapshot, _t)
	
	# Add sinusoidal height (peaks at t=0.5)
	var height := (arc_height + _height_variation) * sin(PI * _t)
	_projectile.global_position = base + Vector3.UP * height
	
	# Look ahead to next position for smooth orientation
	var next_t: float = min(1.0, _t + 0.02)
	var next_base := _start_pos.lerp(_target_snapshot, next_t)
	var next_height := (arc_height + _height_variation) * sin(PI * next_t)
	if _projectile.global_position != next_base + Vector3.UP * next_height:
		_projectile.look_at(next_base + Vector3.UP * next_height)


func _on_retarget() -> void:
	# Recalculate for new target
	_target_snapshot = _target.get_collision_center()
	var distance := _start_pos.distance_to(_target_snapshot)
	_travel_time = max(0.001, distance / max(0.001, speed))
	_height_variation = randf_range(-randomize_by, randomize_by)
