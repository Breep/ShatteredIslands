extends Node3D # Needs to be a Node 3D to get global_position of areas childs of this manager
class_name SpawnManager

# ============================== Signal ==============================

signal all_players_spawned()

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== External Export ==============================

@export var _spawn_points: Array[SpawnPoint]
@export var _spawn_areas: Array[SpawnArea]
@export var _entities_node: Node3D
@export var _projectiles_node: Node3D

# ============================== Private variables ==============================

var _entity_counter: int = 0
var _projectile_counter: int = 0

# ============================== Public function ==============================

# Reparent characters into the FightingArea/Entities node and teleport them on the FightingArea
func spawn_characters(characters: Array[Character]) -> void:
	var _available_spawn_points: Array[SpawnPoint] = _spawn_points.duplicate()
	for character in characters:
		_spawn_character(character, _available_spawn_points)


func spawn_projectile(source: Character, target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	var projectile: Projectile = preload("res://Scenes/SpellsAndProjectiles/projectile.tscn").instantiate()
	projectile.name = "Projectile_" + str(_projectile_counter)
	projectile.position = _projectiles_node.to_local(projectile_spawn.global_position)
	projectile.stats = projectile_stats
	projectile.source = source
	projectile.target = target
	projectile.battle_id = battle_id
	projectile.id = _projectile_counter
	_projectile_counter += 1
	_projectiles_node.add_child(projectile)

# ============================== Private functions ==============================

# spawn an already instatiated character on the _entities_node at a spawn location available
func _spawn_character(character: Character, available_spawn_locations: Array[SpawnPoint]) -> bool:
	if character == null:
		printerr("SpawnManager: Trying to spawn a <null> Character")
		return false
	
	for spawn_point in available_spawn_locations:
		if spawn_point.team == character.team:
			character.reparent(_entities_node)
			character.global_position = spawn_point.global_position
			available_spawn_locations.erase(spawn_point)
			return true
	
	printerr("SpawnManager: No more available spawn point for ", character.name)
	return false






 
