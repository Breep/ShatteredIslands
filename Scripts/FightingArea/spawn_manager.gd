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

func spawn_characters(players: Array[Player]) -> Array[Character]:
	var spawned_characters: Array[Character]
	
	for player in players:
		spawned_characters.append(_spawn_new_character(player))
	
	return spawned_characters


func spawn_projectile(source: Character, target: Character, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	var projectile: Projectile = preload("res://Scenes/SpellsAndProjectiles/projectile.tscn").instantiate()
	projectile.name = "Projectile_" + str(_projectile_counter)
	projectile.position = _projectiles_node.to_local(projectile_spawn.global_position)
	projectile.stats = projectile_stats
	projectile.source_id = source.id
	projectile.target_id = target.id
	projectile.battle_id = battle_id
	projectile.id = _projectile_counter
	_projectile_counter += 1
	_projectiles_node.add_child(projectile)

# ============================== Private functions ==============================

# Instantiate and spawn a new character for the player
func _spawn_new_character(player: Player) -> Character:
	if not multiplayer.is_server():
		return
	
	var character: Character = Shared.CHARACTERS[player.hero.id].instantiate()
	character.id = _entity_counter
	_entity_counter += 1
	character.battle_id = battle_id
	character.team = player.team
	character.owner_player_id = player.id
	
	for spawn_point in _spawn_points:
		if spawn_point.team == character.team:
			character.position = _entities_node.to_local(spawn_point.global_position)
			_spawn_points.erase(spawn_point)
			break
	
	_entities_node.add_child(character)
	return character






 
