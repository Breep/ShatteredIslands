class_name FightingFloor
extends Node3D

@export var _visual_to_be_destroyed: MeshInstance3D

@export var _character_spawner: CharacterSpawner
@export var _spawn_areas: Array[SpawnArea]
@export var _floor: StaticBody3D

var _is_active: bool = false

func _ready() -> void:
	_visual_to_be_destroyed.queue_free()


func set_active() -> CharacterSpawner:
	if _is_active: return _character_spawner
	_is_active = true
	for spawn_area in _spawn_areas:
		spawn_area.monitorable = true
	return _character_spawner


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	for spawn_area in _spawn_areas:
		spawn_area.monitorable = false
