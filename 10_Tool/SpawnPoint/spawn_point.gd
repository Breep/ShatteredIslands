class_name SpawnPoint
extends Node3D

@export var team: int

@onready var _to_be_destroyed: MeshInstance3D = %VisualToBeDestroyed

func _ready() -> void:
	_to_be_destroyed.queue_free()
