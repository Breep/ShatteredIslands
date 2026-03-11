class_name AnimHoveringModule
extends Node

enum Axis {
	X,
	Y,
	Z
}

@onready var _tween := create_tween()

@export var _owner: Node3D

@export var _hover_power: float
@export var _hover_period: float
@export var _random_start: bool

@export var _axe: Axis = Axis.Y

func _ready():
	if _owner == null:
		printerr("AnimHoverModule: Owner isn't set ! [", get_path(), "]")
		return
	
	if _random_start:
		await get_tree().create_timer(Utils.get_randf_range(0.0, 2.0)).timeout
	
	start_hover()

func start_hover():
	_tween.set_loops()
	match _axe:
		Axis.X:
			var up = _owner.position.x - _hover_power
			var down = _owner.position.x + _hover_power
			_tween.tween_property(_owner, "position:x", up, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "position:x", down, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Axis.Y:
			var up = _owner.position.y - _hover_power
			var down = _owner.position.y + _hover_power
			_tween.tween_property(_owner, "position:y", up, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "position:y", down, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Axis.Z:
			var up = _owner.position.z - _hover_power
			var down = _owner.position.z + _hover_power
			_tween.tween_property(_owner, "position:z", up, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(_owner, "position:z", down, _hover_period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
