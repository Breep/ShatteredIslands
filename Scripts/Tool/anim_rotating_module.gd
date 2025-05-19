class_name AnimRotatingModule
extends Node

enum AXIS {
	X,
	Y,
	Z
}

@onready var _tween := create_tween()

@export var _owner: Node3D

@export var _rot_axis: AXIS
@export var _rot_period: float
@export var _rot_max: float
@export var _rot_full: bool

func _ready():
	if _owner == null:
		printerr("AnimHoverModule: Owner isn't set !")
		return
	
	if _rot_full:
		_start_endless_rotating()
	else:
		_start_back_and_forth_rotating()

func _start_back_and_forth_rotating():
	_tween.set_loops() # infinite
	
	match _rot_axis:
		AXIS.X:
			var x_rot_min = _owner.rotation.x - deg_to_rad(_rot_max)
			var x_rot_max = _owner.rotation.x + deg_to_rad(_rot_max)
			_tween.tween_property(_owner, "rotation:x", x_rot_max, _rot_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "rotation:x", x_rot_min, _rot_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		AXIS.Y:
			var y_rot_min = _owner.rotation.y - deg_to_rad(_rot_max)
			var y_rot_max = _owner.rotation.y + deg_to_rad(_rot_max)
			_tween.tween_property(_owner, "rotation:y", y_rot_max, _rot_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "rotation:y", y_rot_min, _rot_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		AXIS.Z:
			var z_rot_min = _owner.rotation.z - deg_to_rad(_rot_max)
			var z_rot_max = _owner.rotation.z + deg_to_rad(_rot_max)
			_tween.tween_property(_owner, "rotation:z", z_rot_max, _rot_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "rotation:z", z_rot_min, _rot_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _start_endless_rotating():
	var tween = create_tween()
	var start_rot = _owner.rotation
	var delta_rot = Vector3.ZERO

	match _rot_axis:
		AXIS.X: delta_rot.x = deg_to_rad(_rot_max)
		AXIS.Y: delta_rot.y = deg_to_rad(_rot_max)
		AXIS.Z: delta_rot.z = deg_to_rad(_rot_max)

	tween.tween_property(_owner, "rotation", start_rot + delta_rot, _rot_period).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.connect("finished", Callable(self, "_start_endless_rotating"))
