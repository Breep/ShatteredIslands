class_name ZigzagTrajectory
extends ProjectileTrajectory

## Zigzag trajectory that adds lateral sine wave motion while advancing.
## Creates a side-to-side wobble effect as the projectile travels.

@export var amplitude: float = 0.5             # Lateral offset amplitude
@export var frequency: float = 5.0             # Cycles per second
@export var vertical_offset: float = 1.0       # Height offset from target

var _travel_time: float
var _target_snapshot: Vector3
var _forward_dir: Vector3
var _right_dir: Vector3


func _on_init() -> void:
	_target_snapshot = _target.global_position + Vector3.UP * vertical_offset
	var distance := _start_pos.distance_to(_target_snapshot)
	_travel_time = max(0.001, distance / max(0.001, speed))
	
	# Calculate forward and right vectors for zigzag
	_forward_dir = (_target_snapshot - _start_pos).normalized()
	var up := Vector3.UP
	_right_dir = up.cross(_forward_dir)
	
	# Fallback if forward is parallel to up
	if _right_dir.length_squared() < 0.0001:
		_right_dir = Vector3.RIGHT
	_right_dir = _right_dir.normalized()


func update(delta: float) -> void:
	_t = min(1.0, _t + delta / _travel_time)
	
	# Base position along straight path
	var base := _start_pos.lerp(_target_snapshot, _t)
	
	# Add lateral sine wave offset
	var time_elapsed := _t * _travel_time
	var lateral_offset := _right_dir * (amplitude * sin(2.0 * PI * frequency * time_elapsed))
	
	_projectile.global_position = base + lateral_offset
	
	# Look roughly forward along the path
	_projectile.look_at(base + _forward_dir)


func _on_retarget() -> void:
	_target_snapshot = _target.global_position + Vector3.UP * vertical_offset
	var distance := _start_pos.distance_to(_target_snapshot)
	_travel_time = max(0.001, distance / max(0.001, speed))
	
	_forward_dir = (_target_snapshot - _start_pos).normalized()
	var up := Vector3.UP
	_right_dir = up.cross(_forward_dir)
	
	if _right_dir.length_squared() < 0.0001:
		_right_dir = Vector3.RIGHT
	_right_dir = _right_dir.normalized()
