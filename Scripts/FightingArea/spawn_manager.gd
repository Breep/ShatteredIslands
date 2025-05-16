extends Node3D # Needs to be a Node 3D to get global_position of areas childs of this manager
class_name SpawnManager

# ============================== Signal ==============================

signal all_players_spawned()

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== Local Export ==============================

@export var character_scene: PackedScene
@export var _spawn_areas: Array[Area3D]

# ============================== Local nodes ==============================

@onready var _entities_node: Node3D = %Entities
@onready var _projectiles_node: Node3D = %Projectiles

# ============================== Private variables ==============================

var _entity_counter: int = 0
var _projectile_counter: int = 0

enum SpawnType {
	SPAWN_AREA, # Big rectangle area where the character can be moved during the countdown
	SPAWN_LOCATIONS, # Array of vecotr3 locations where the cchracter are first spawned at the beginning of the countdown
	SPAWN_CHARACTER_NUMBER, # Number of character already spawned for a team
}
var _spawns_data: Dictionary # {String:Dictionary{SpawnType:Area3D, SpawnType:Array[Vector3D], SpawnType:int}}

enum TeamsData {
	TEAMS_NUMBER, # Number of teams (Can be 1, 2, 3, 4, 5, 6, 7 or 8)
	TEAMS_PLAYER_NUMBER, # Number of player in each team (can be 1, 2, 3 or 4)
}
var _teams_data: Dictionary # {TeamsData.TEAM_NUMBER:int, TeamsData.TEAM_PLAYER_NUMBER:int}

# ============================== Public function ==============================

func spawn_characters(players: Array[Player]) -> Array[Character]:
	var spawned_characters: Array[Character]
	
	if not _init_teams_data(players):
		printerr("SpawnManager: Can't init teams data")
		return []
	
	if not _init_spawns_data(_teams_data[TeamsData.TEAMS_NUMBER], _teams_data[TeamsData.TEAMS_PLAYER_NUMBER]):
		printerr("SpawnManager: Can't init spawns data")
		return []
	
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
	character.position = to_local(_get_spawn_global_position(character.team))
	_entities_node.add_child(character)
	return character


# Init spawns data: /!\ There should be only one spawn area for each team
# All spawn areas must be a rectangle, spawns location are calculated along z axis
func _init_spawns_data(number_of_teams: int, team_players_number: int) -> bool:
	for team_number in range(1, number_of_teams + 1):
		var spawn_team_group_name: String = "SPAWN_TEAM_" + str(team_number) 
		var team_spawn_areas: Array[Area3D]
		for spawn_area in _spawn_areas:
			if spawn_area.is_in_group(spawn_team_group_name):
				team_spawn_areas.append(spawn_area)
		if team_spawn_areas.is_empty():
			printerr("SpawnManager: No spawn area for team ", team_number, " !")
			return false
		if team_spawn_areas.size() > 1:
			printerr("SpawnManager: Too many spawn areas for team ", team_number, " !")
			return false
		for area in team_spawn_areas:
			var spawn_data: Dictionary
			spawn_data[SpawnType.SPAWN_AREA] = area
			spawn_data[SpawnType.SPAWN_LOCATIONS] = _get_spawns_locations(area, team_players_number)
			spawn_data[SpawnType.SPAWN_CHARACTER_NUMBER] = 0
			_spawns_data[spawn_team_group_name] = spawn_data
	return true


# From the array of player passed to the SpawnManager, get teams number and player numbers of each team
# Can return false if there is somethings wrong (Too many teams, not enough or not the same amount of player in each team)
func _init_teams_data(players: Array[Player]) -> bool:
	var teams_number_of_player: Dictionary
	
	# Get all number of players for each team
	for player in players:
		if teams_number_of_player.has(player.team):
			teams_number_of_player[player.team] += 1
		else:
			teams_number_of_player[player.team] = 1
	
	# Check coherency for the number of teams
	if teams_number_of_player.keys().size() <= 1:
		printerr("SpawnManager: There is not enough teams")
		return false
	elif teams_number_of_player.keys().size() > 8:
		printerr("SpawnManager: There is too many teams")
		return false
	
	# Check coherency for number of players in each team
	var old_players_number_in_team: int = teams_number_of_player[1]
	for team_number in teams_number_of_player.keys():
		if teams_number_of_player[team_number] != old_players_number_in_team:
			printerr("The number of player in each team is not consistent")
			return false
		else:
			old_players_number_in_team = teams_number_of_player[team_number]
	
	_teams_data[TeamsData.TEAMS_NUMBER] = teams_number_of_player.keys().size()
	_teams_data[TeamsData.TEAMS_PLAYER_NUMBER] = teams_number_of_player[1]
	return true


func _get_spawns_locations(_spawns_area: Area3D, team_players_number: int) -> Array[Vector3]:
	var positions: Array[Vector3]
	for i in team_players_number:
		var spawn_position: Vector3
		var collision_shape_3d = (_spawns_area.get_child(0) as CollisionShape3D)
		if collision_shape_3d == null:
			printerr("SpawnManager: No collision shape 3d in the spawn area ! [", _spawns_area, "]")
		var area_size_z = (collision_shape_3d.shape as BoxShape3D).size.z
		spawn_position.x = _spawns_area.global_position.x
		spawn_position.y = _spawns_area.global_position.y
		var top_z = _spawns_area.global_position.z - area_size_z / 2
		spawn_position.z =  top_z + (i + 1) * area_size_z / (team_players_number + 1)
		positions.append(spawn_position)
	return positions


# Get the character first spawn location, the location will change depending on the team_number and how often this function is called
func _get_spawn_global_position(team_number: int) -> Vector3:
	var spawn_team_group: String = "SPAWN_TEAM_" + str(team_number)
	var spawn_data: Dictionary = _spawns_data[spawn_team_group]
	var spawn_locations: Array[Vector3] = spawn_data[SpawnType.SPAWN_LOCATIONS]
	var number_of_character_spawned_for_this_team: int = spawn_data[SpawnType.SPAWN_CHARACTER_NUMBER]
	spawn_data[SpawnType.SPAWN_CHARACTER_NUMBER] += 1
	return spawn_locations[number_of_character_spawned_for_this_team]
	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
