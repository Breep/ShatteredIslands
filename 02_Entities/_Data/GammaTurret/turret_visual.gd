class_name TurretVisual
extends Node3D

var _anim_player: AnimationPlayer
var _shoot_right: bool = true


func _ready() -> void:
	_anim_player = $turret_v2/AnimationPlayer


func play_shoot_animation() -> void:
	if _anim_player == null:
		return
	if _shoot_right:
		_anim_player.play(&"canon droitAction")
	else:
		_anim_player.play(&"canon gaucheAction")
	_shoot_right = !_shoot_right
