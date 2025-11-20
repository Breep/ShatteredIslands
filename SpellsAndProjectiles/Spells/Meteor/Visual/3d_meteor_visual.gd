extends Node3D

@onready var  _anim_player = %AnimationPlayer

func _ready() -> void:
	if _anim_player and _anim_player.has_animation("meteor"):
		_anim_player.play("meteor")
