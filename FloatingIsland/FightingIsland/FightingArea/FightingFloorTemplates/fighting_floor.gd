class_name FightingFloor
extends Node3D

@export var _visual_to_be_destroyed: MeshInstance3D

@export var _hero_spawner: HeroSpawner
@export var _spawn_areas: Array[SpawnArea]

var _is_active: bool = false

func _ready() -> void:
	_visual_to_be_destroyed.queue_free()


func set_active() -> HeroSpawner:
	if _is_active: return _hero_spawner
	_is_active = true
	for spawn_area in _spawn_areas:
		spawn_area.monitorable = true
	return _hero_spawner


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	for spawn_area in _spawn_areas:
		spawn_area.monitorable = false
