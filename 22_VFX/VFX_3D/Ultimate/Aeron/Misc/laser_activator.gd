extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("Init")

func _on_beam_appears()->void:
	get_parent().get_node("Marker3D/Camera3D").start_shake()
