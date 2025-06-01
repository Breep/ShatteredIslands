class_name FightingFloor
extends Node3D

@export var _visual_to_be_destroyed: MeshInstance3D

@export var _spawn_manager: SpawnManager
@export var _spawn_areas: Array[SpawnArea]
@export var _floor: StaticBody3D
@export var _walls: Array[Area3D]

var _is_active: bool = false

func _ready() -> void:
	_visual_to_be_destroyed.queue_free()


func set_active() -> SpawnManager:
	if _is_active: return _spawn_manager
	_is_active = true
	for spawn_area in _spawn_areas:
		spawn_area.monitorable = true
	for wall in _walls:
		wall.monitorable = true
	return _spawn_manager


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	for spawn_area in _spawn_areas:
		spawn_area.monitorable = false
	for wall in _walls:
		wall.monitorable = false
