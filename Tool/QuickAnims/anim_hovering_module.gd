class_name AnimHoveringModule
extends Node

enum Axis {
	X,
	Y,
	Z
}

var _tween: Tween
var _origin: float

@export var _owner: Node3D

@export var _hover_power: float
@export var _hover_period: float
@export var _random_start: bool

@export var _axe: Axis = Axis.Y

func _ready() -> void:
	if _owner == null:
		printerr("AnimHoverModule: Owner isn't set ! [", get_path(), "]")
		return
	
	if _random_start:
		await get_tree().create_timer(Utils.get_randf_range(0.0, 2.0)).timeout
	
	start_hover()


#region ============================== Public API ==============================
func start_hover() -> void:
	if is_instance_valid(_tween):
		_tween.kill()

	match _axe:
		Axis.X: _origin = _owner.position.x
		Axis.Y: _origin = _owner.position.y
		Axis.Z: _origin = _owner.position.z

	_tween = create_tween().set_loops()
	match _axe:
		Axis.X:
			_tween.tween_property(_owner, "position:x", _origin - _hover_power, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "position:x", _origin + _hover_power, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Axis.Y:
			_tween.tween_property(_owner, "position:y", _origin - _hover_power, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "position:y", _origin + _hover_power, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Axis.Z:
			_tween.tween_property(_owner, "position:z", _origin - _hover_power, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "position:z", _origin + _hover_power, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func stop_hover() -> void:
	if is_instance_valid(_tween):
		_tween.kill()
		_tween = null
#endregion
