class_name SpawnArea
extends Area3D

@export var team: int

@export var _visual_to_be_destroyed: MeshInstance3D

func _ready() -> void:
	_visual_to_be_destroyed.queue_free()
