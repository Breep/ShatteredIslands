extends Node
class_name CharacterSpawner

# ============================== Signal ==============================

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== External Export ==============================

@export var _spawn_points: Array[SpawnPoint]

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public function ==============================

# Reparent characters into the node_to_spawn_into node and teleport them on the FightingArea
func spawn_characters(characters: Array[Character], node_to_spawn_into: Node3D) -> void:
	Verbose.debug("Spawning Characters | " + str(characters.size()), Verbose.Category.CHARACTER_SPAWNER)
	var _available_spawn_points: Array[SpawnPoint] = _spawn_points.duplicate()
	for character in characters:
		_spawn_character(character, _available_spawn_points, node_to_spawn_into)

# ============================== Private functions ==============================

# spawn an already instatiated character on the _entities_node at a spawn location available
func _spawn_character(character: Character, available_spawn_locations: Array[SpawnPoint], node_to_spawn_into: Node3D) -> bool:
	if character == null:
		Verbose.error("Trying to spawn a <null> Character", Verbose.Category.CHARACTER_SPAWNER)
		return false
	
	for spawn_point in available_spawn_locations:
		if spawn_point.team == character.team:
			character.reparent(node_to_spawn_into)
			character.global_position = spawn_point.global_position
			character.global_rotation = spawn_point.global_rotation
			available_spawn_locations.erase(spawn_point)
			return true
	
	Verbose.error("No more available spawn point for " + character.name + " [Team#" + str(character.team) + "]", Verbose.Category.CHARACTER_SPAWNER)
	return false 
