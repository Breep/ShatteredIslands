class_name FightingFloor
extends Node3D

@export var _visual_to_be_destroyed: MeshInstance3D

@export var _hero_spawner: HeroSpawner

# Arena zones for spawn location system
@export var _team_zones: Dictionary[int, Area3D] = {}
@export var _center_zone: Area3D = null
@export var _full_arena_zone: Area3D = null

var _is_active: bool = false

func _ready() -> void:
	if _visual_to_be_destroyed != null:
		_visual_to_be_destroyed.queue_free()


func set_active() -> HeroSpawner:
	if _is_active: return _hero_spawner
	_is_active = true
	return _hero_spawner


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
