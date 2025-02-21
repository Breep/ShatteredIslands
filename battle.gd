class_name Battle
extends Resource

enum BattleType {
	VS_1, # 1v1
	VS_2, # 2v2
	VS_3, # 3v3
	VS_4, # 4v4
	FFA_SOLO_3, # 1v1v1
	FFA_SOLO_4, # 1v1v1v1
	FFA_SOLO_5, # 1v1v1v1v1
	FFA_SOLO_6, # 1v1v1v1v1v1
	FFA_SOLO_7, # 1v1v1v1v1v1v1
	FFA_SOLO_8, # 1v1v1v1v1v1v1v1
	FFA_DUO_6, # 2v2v2
	FFA_DUO_8, # 2v2v2v2
}

var battle_type: BattleType
var name: String

var players_number: int
var teams_number: int

var players: Array[Player]


# Pickup random players from a players dictionary and put them into the battle, also remove those players from the players_list
func fill_with_players(players_list: Dictionary) -> void:
	if players_number < 2 or teams_number < 2:
		printerr("Battle: Can't fill with players")
		return
	
	for i in players_number:
		var player = _pick_random_player(players_list)
		players.append(player)


# Put players in differents teams
func sort_players_in_team() -> void:
	if players_number < 2 or teams_number < 2 or players.is_empty():
		printerr("Battle: Can't sort players in team")
		return
	
	var players_per_team = players_number / teams_number
	for team_index in teams_number:
		for i in players_per_team:
			players[team_index * players_per_team + i].team = team_index + 1


# Pick a random player from players dictionary and remove it from the dictionary
func _pick_random_player(players: Dictionary) -> Player:
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var player_index = rng.randi_range(0, players.size() - 1)
	var player = players.values()[player_index]
	players.erase(players.find_key(player))
	return player
