extends Node3D

@export var _size: float = 2.0

var player: Player
var hero: Hero
var stats: CharacterStats

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
	(_mesh_instance.mesh as BoxMesh).size = Vector3(_size, _size, _size)
	print("[", multiplayer.get_unique_id(), "] : New CUBE")
