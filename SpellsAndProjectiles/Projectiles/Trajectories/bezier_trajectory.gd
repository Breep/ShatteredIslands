class_name BezierTrajectory
extends ProjectileTrajectory

## Bezier curve trajectory using a quadratic Bezier with elevated control point.
## Creates a smooth curved path with configurable height at the midpoint.

@export var control_height: float = 5.0        # Height of the control point above midpoint
@export var randomize_by: float = 0.5          # ± randomness on control height
@export var vertical_offset: float = 1.0       # Height offset from target

var _travel_time: float
var _target_snapshot: Vector3
var _control_point: Vector3
var _height_variation: float


func _on_init() -> void:
	_target_snapshot = _target.get_collision_center()
	var distance := _start_pos.distance_to(_target_snapshot)
	_travel_time = max(0.001, distance / max(0.001, speed))
	_height_variation = randf_range(-randomize_by, randomize_by)
	
	# Calculate control point: midpoint + upward offset
	var midpoint := (_start_pos + _target_snapshot) * 0.5
	_control_point = midpoint + Vector3.UP * (control_height + _height_variation)


func update(delta: float) -> void:
	_t = min(1.0, _t + delta / _travel_time)
	
	# Quadratic Bezier: B(t) = (1-t)²P0 + 2(1-t)tP1 + t²P2
	# Or using double lerp: lerp(lerp(P0, P1, t), lerp(P1, P2, t), t)
	var a := _start_pos.lerp(_control_point, _t)
	var b := _control_point.lerp(_target_snapshot, _t)
	var position := a.lerp(b, _t)
	
	_projectile.global_position = position
	
	# Look toward next position for orientation
	var direction := (b - a).normalized()
	if direction.length_squared() > 0.001:
		_projectile.look_at(position + direction)


func _on_retarget() -> void:
	_target_snapshot = _target.get_collision_center()
	var distance := _start_pos.distance_to(_target_snapshot)
	_travel_time = max(0.001, distance / max(0.001, speed))
	_height_variation = randf_range(-randomize_by, randomize_by)
	
	var midpoint := (_start_pos + _target_snapshot) * 0.5
	_control_point = midpoint + Vector3.UP * (control_height + _height_variation)
