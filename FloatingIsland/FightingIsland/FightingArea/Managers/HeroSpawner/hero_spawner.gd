extends Node
class_name HeroSpawner

# ============================== Signal ==============================

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== External Export ==============================

@export var _spawn_points: Array[SpawnPoint]

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public function ==============================

# Reparent heroes into the node_to_spawn_into node and teleport them on the FightingArea
func spawn_heroes(heroes: Array[Hero], node_to_spawn_into: Node3D) -> void:
	Verbose.debug("Spawning Heroes | " + str(heroes.size()), Verbose.Category.HERO_SPAWNER)
	var _available_spawn_points: Array[SpawnPoint] = _spawn_points.duplicate()
	for hero: Hero in heroes:
		_spawn_hero(hero, _available_spawn_points, node_to_spawn_into)

# ============================== Private functions ==============================

# spawn an already instatiated hero on the _entities_node at a spawn location available
func _spawn_hero(hero: Hero, available_spawn_locations: Array[SpawnPoint], node_to_spawn_into: Node3D) -> bool:
	if hero == null:
		Verbose.error("Trying to spawn a <null> Hero", Verbose.Category.HERO_SPAWNER)
		return false
	
	if hero.is_inside_tree():
		Verbose.warn("Hero " + hero.entity_name + " already in tree, this shouldn't happen", Verbose.Category.HERO_SPAWNER)
		return false
	
	for spawn_point: SpawnPoint in available_spawn_locations:
		if spawn_point.team == hero.team:
			node_to_spawn_into.add_child(hero)
			hero.global_position = spawn_point.global_position
			hero.global_rotation = spawn_point.global_rotation
			available_spawn_locations.erase(spawn_point)
			return true
	
	Verbose.error("No more available spawn point for " + hero.name + " [Team#" + str(hero.team) + "]", Verbose.Category.HERO_SPAWNER)
	return false
