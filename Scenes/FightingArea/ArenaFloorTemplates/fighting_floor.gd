class_name FightingFloor
extends Node3D

@export var _visual_to_be_destroyed: MeshInstance3D

func _ready() -> void:
	_visual_to_be_destroyed.queue_free()
