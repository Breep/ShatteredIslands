extends Node3D

func _ready() -> void:
	var anim_player: AnimationPlayer = $AnimationPlayer
	if anim_player and anim_player.has_animation("meteor"):
		anim_player.play("meteor")
