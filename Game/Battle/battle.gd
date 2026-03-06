class_name Battle
extends Resource

# ============================== Enums ==============================

enum BattleType {
	VS_1, # 1v1
	VS_2, # 2v2
	#VS_3, # 3v3
	#VS_4, # 4v4
	FFA_SOLO_3, # 1v1v1
	#FFA_SOLO_4, # 1v1v1v1
	#FFA_SOLO_5, # 1v1v1v1v1
	#FFA_SOLO_6, # 1v1v1v1v1v1
	#FFA_SOLO_7, # 1v1v1v1v1v1v1
	#FFA_SOLO_8, # 1v1v1v1v1v1v1v1
	#FFA_DUO_6, # 2v2v2
	#FFA_DUO_8, # 2v2v2v2
}

enum BattleCategory {
	C2_PLAYERS_BATTLE = 2, # 2 players battle
	C3_PLAYERS_BATTLE = 3, # 3 players battle
	C4_PLAYERS_BATTLE = 4, # 4 players battle
}

enum BattleResolution {
	WIN,
	LOOSE
}

# ============================== Constants ==============================

const BATTLES_INFO_DIC = {
	BattleType.VS_1: {
		"name": "1v1",
		"players_number": 2,
		"teams_number": 2,
	},
	BattleType.VS_2: {
		"name": "2v2",
		"players_number": 4,
		"teams_number": 2,
	},
	#BattleType.VS_3: {
		#"name": "3v3",
		#"players_number": 6,
		#"teams_number": 2,
	#},
	#BattleType.VS_4: {
		#"name": "4v4",
		#"players_number": 8,
		#"teams_number": 2,
	#},
	BattleType.FFA_SOLO_3: {
		"name": "1v1v1",
		"players_number": 3,
		"teams_number": 3,
	},
	#BattleType.FFA_SOLO_4: {
		#"name": "1v1v1v1",
		#"players_number": 4,
		#"teams_number": 4,
	#},
	#BattleType.FFA_SOLO_5: {
		#"name": "1v1v1v1v1",
		#"players_number": 5,
		#"teams_number": 5,
	#},
	#BattleType.FFA_SOLO_6: {
		#"name": "1v1v1v1v1v1",
		#"players_number": 6,
		#"teams_number": 6,
	#},
	#BattleType.FFA_SOLO_7: {
		#"name": "1v1v1v1v1v1v1",
		#"players_number": 7,
		#"teams_number": 7,
	#},
	#BattleType.FFA_SOLO_8: {
		#"name": "1v1v1v1v1v1v1v1",
		#"players_number": 8,
		#"teams_number": 8,
	#},
	#BattleType.FFA_DUO_6: {
		#"name": "2v2v2",
		#"players_number": 6,
		#"teams_number": 3,
	#},
	#BattleType.FFA_DUO_8: {
		#"name": "2v2v2v2",
		#"players_number": 8,
		#"teams_number": 4,
	#},
}


# Key=<number of players in the battle> | Value=<array of possible battle type>
const BATTLES_TYPE_DIC = {
	BattleCategory.C2_PLAYERS_BATTLE: [Battle.BattleType.VS_1],
	BattleCategory.C3_PLAYERS_BATTLE: [Battle.BattleType.FFA_SOLO_3],
	BattleCategory.C4_PLAYERS_BATTLE: [Battle.BattleType.VS_2], #, Battle.BattleType.FFA_SOLO_4], # A fight with 4 players can be done either with a 2v2 or a 1v1v1v1
	#5: [Battle.BattleType.FFA_SOLO_5],
	#6: [Battle.BattleType.VS_3, Battle.BattleType.FFA_SOLO_6, Battle.BattleType.FFA_DUO_6],
	#7: [Battle.BattleType.FFA_SOLO_7],
	#8: [Battle.BattleType.VS_4, Battle.BattleType.FFA_SOLO_8, Battle.BattleType.FFA_DUO_8],
}

# ============================== Public variables ==============================

var id: int

var battle_type: BattleType
var name: String

var players_number: int
var teams_number: int

var players: Array[Player]

# ============================== Serialization ==============================

static func new_from_serialized(serialized_data: Dictionary) -> Battle:
	var battle := Battle.new()
	battle.id = serialized_data["id"]
	battle.battle_type = serialized_data["battle_type"]
	battle.name = serialized_data["name"]
	battle.players_number = serialized_data["players_number"]
	battle.teams_number = serialized_data["teams_number"]
	for player_id: int in serialized_data["player_ids"]:
		battle.players.append(PlayerManager.players[player_id])
	return battle


func serialized() -> Dictionary:
	var player_ids: Array[int]
	for player in players:
		player_ids.append(player.id)
	var serialized_version = {
		"id": id,
		"battle_type": battle_type,
		"name": name,
		"players_number": players_number,
		"teams_number": teams_number,
		"player_ids": player_ids
	}
	return serialized_version

# ============================== Public functions ==============================

# Create a new empty battle randomly picked from a category (no players assiociated to it)
static func new_from_category(battle_category: BattleCategory) -> Battle:
	var battle := Battle.new()
	var random_battle_type = _get_random_battle_type(battle_category)
	var battle_info = BATTLES_INFO_DIC[random_battle_type]
	battle.battle_type = random_battle_type
	battle.name = battle_info["name"]
	battle.players_number = battle_info["players_number"]
	battle.teams_number = battle_info["teams_number"]
	return battle


# Pickup random players from a players dictionary and put them into the battle
# /!\ It removes those players from the players_list /!\
# Put players in differents teams
func fill_with_players(players_list: Dictionary) -> void:
	if players_number < 2 or teams_number < 2:
		printerr("Battle: Can't fill with players")
		return
	
	for i in players_number:
		var player = _pick_random_player(players_list)
		players.append(player)
	
	_sort_players_in_team()


func _sort_players_in_team() -> void:
	if players_number < 2 or teams_number < 2 or players.is_empty():
		printerr("Battle: Can't sort players in team")
		return
	
	var players_per_team: int = floor(players_number as float / teams_number as float)
	for team_index in teams_number:
		for i in players_per_team:
			players[team_index * players_per_team + i].team = team_index + 1

# ============================== Private functions ==============================

# Pick a random player from players dictionary and remove it from the dictionary
func _pick_random_player(players_list: Dictionary) -> Player:
	var player_index = Utils.get_randi_range(0, players_list.size() - 1)
	var player = players_list.values()[player_index]
	players_list.erase(players_list.find_key(player))
	return player


# Get a random battle_type from a number of players (If there are 4 players in a fight, it can be either a 2v2 or a 1v1v1v1 for instance)
static func _get_random_battle_type(battle_category: BattleCategory) -> Battle.BattleType:
	var battle_types: Array = BATTLES_TYPE_DIC[battle_category]
	var battle_id = Utils.get_randi_range(0, battle_types.size() - 1)
	return battle_types[battle_id]
