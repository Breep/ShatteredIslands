class_name RoundManager
extends Node

var round_number: int

# Calcul du gain du match précédent
# Répartition des joueurs par équipe
# Lancer la scène d'achat
# Lancer la scène de combat

# Key=<number of players in the battle> | Value=<array of possible battle type>
var _battles_type_dic = {
	2: [Battle.BattleType.VS_1],
	3: [Battle.BattleType.FFA_SOLO_3],
	4: [Battle.BattleType.VS_2, Battle.BattleType.FFA_SOLO_4], # A fight with 4 players can be done either with a 2v2 or a 1v1v1v1
	5: [Battle.BattleType.FFA_SOLO_5],
	6: [Battle.BattleType.VS_3, Battle.BattleType.FFA_SOLO_6, Battle.BattleType.FFA_DUO_6],
	7: [Battle.BattleType.FFA_SOLO_7],
	8: [Battle.BattleType.VS_4, Battle.BattleType.FFA_SOLO_8, Battle.BattleType.FFA_DUO_8],
}

# Key=<number of players still alive> | Value=<array of possible combinations>
var _battles_combinations_dic = {
	2: [[2]],
	3: [[3]],
	4: [[2, 2], [4]], # If there are 4 players alive, there are two ways of doing the next round: 2 fights of 2 players or 1 fight of 4 players
	5: [[2, 3], [5]],
	6: [[2, 2, 2], [3, 3], [2, 4], [6]],
	7: [[2, 2, 3], [4, 3], [2, 5], [7]],
	8: [[2, 2, 2, 2], [2, 3, 3], [2, 6], [3, 5], [4, 4], [8]]
}

var _battles_info_dic = {
	Battle.BattleType.VS_1: {
		"name": "1v1",
		"players_number": 2,
		"teams_number": 2,
	},
	Battle.BattleType.VS_2: {
		"name": "2v2",
		"players_number": 4,
		"teams_number": 2,
	},
	Battle.BattleType.VS_3: {
		"name": "3v3",
		"players_number": 6,
		"teams_number": 2,
	},
	Battle.BattleType.VS_4: {
		"name": "4v4",
		"players_number": 8,
		"teams_number": 2,
	},
	Battle.BattleType.FFA_SOLO_3: {
		"name": "1v1v1",
		"players_number": 3,
		"teams_number": 3,
	},
	Battle.BattleType.FFA_SOLO_4: {
		"name": "1v1v1v1",
		"players_number": 4,
		"teams_number": 4,
	},
	Battle.BattleType.FFA_SOLO_5: {
		"name": "1v1v1v1v1",
		"players_number": 5,
		"teams_number": 5,
	},
	Battle.BattleType.FFA_SOLO_6: {
		"name": "1v1v1v1v1v1",
		"players_number": 6,
		"teams_number": 6,
	},
	Battle.BattleType.FFA_SOLO_7: {
		"name": "1v1v1v1v1v1v1",
		"players_number": 7,
		"teams_number": 7,
	},
	Battle.BattleType.FFA_SOLO_8: {
		"name": "1v1v1v1v1v1v1v1",
		"players_number": 8,
		"teams_number": 8,
	},
	Battle.BattleType.FFA_DUO_6: {
		"name": "2v2v2",
		"players_number": 6,
		"teams_number": 3,
	},
	Battle.BattleType.FFA_DUO_8: {
		"name": "2v2v2v2",
		"players_number": 8,
		"teams_number": 4,
	},
}

var _tmp_players: Dictionary
var _battles: Array[Battle]


# Get a random set of battles according to the alive players number
# Fill the battle with random players and sort them in team randomly
func get_current_round_battles(alive_players: Dictionary) -> Array[Battle]:
	var players_duplicate = alive_players.duplicate()
	var battles: Array[Battle] = []
	
	# Get a battle combination
	var battle_combination = _get_battle_combination(_tmp_players.size())
	
	# Construct the _battles array with all battle, fill them with players, assigned team to players
	for player_number in battle_combination:
		var battle_type = _get_battle_type(player_number)
		var battle_info = _battles_info_dic[battle_type]
		var battle = Battle.new()
		battle.battle_type = battle_type
		battle.name = battle_info["name"]
		battle.players_number = battle_info["players_number"]
		battle.teams_number = battle_info["teams_number"]
		battle.fill_with_players(players_duplicate)
		battle.sort_players_in_team()
		battles.append(battle)
	
	return battles


# Get a random battle_combination from a number of players alive
func _get_battle_combination(alive_players_number: int) -> Array:
	var battle_combinations: Array = _battles_combinations_dic[alive_players_number]
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var combination_id = rng.randi_range(0, battle_combinations.size() - 1)
	return battle_combinations[combination_id]


# Get a random battle_type from a number of players (If there are 4 players in a fight, it can be either a 2v2 or a 1v1v1v1 for instance)
func _get_battle_type(number_of_players: int) -> Battle.BattleType:
	var battle_types: Array = _battles_type_dic[number_of_players]
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var battle_id = rng.randi_range(0, battle_types.size() - 1)
	return battle_types[battle_id]


func _ready() -> void:
	for i in 8:
		var player = Player.new()
		player.name = "Breep_" + str(i)
		player.id = i * 10
		player.health = 30
		_tmp_players[player.id] = player

	var battles = get_current_round_battles(_tmp_players)
	
	
	print("coucou")


















 
