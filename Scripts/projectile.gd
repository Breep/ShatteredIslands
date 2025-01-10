extends Area2D
class_name Projectile

# ============================== Private ==============================

var _target: Player
var _speed: float = 1
const _SPEED_MIN: float = 0.3
var _dammage: int
const _DAMMAGE_MIN: int = 1

# ============================== Public ==============================

var speed: float:
	get:
		return _speed
	set(value):
		if value < _SPEED_MIN:
			_speed = _SPEED_MIN
		else:
			_speed = value

var target: Player:
	get:
		return _target
	set(value):
		if value == null:
			printerr("Trying to instantiate a projectile with no target !")
		else:
			_target = value

var dammage: int:
	get:
		return _speed
	set(value):
		if value < _DAMMAGE_MIN:
			_dammage = _DAMMAGE_MIN
		else:
			_dammage = value

# ============================== Node base functions ==============================

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	_moveTowardTarget(delta)

# ============================== Private functions ==============================

func _moveTowardTarget(delta: float):
	if _target == null:
		printerr("Projectile [", name, "] is alive but with no target")
		return
	
	var direction: Vector2 = (_target.global_position - global_position).normalized()
	position += direction * _speed * delta
	look_at(_target.global_position)

# ============================== public functions ==============================

# ============================== Collision functions ==============================

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body == _target:
		queue_free()
