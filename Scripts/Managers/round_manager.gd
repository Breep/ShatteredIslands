extends Node

var current_round: int

signal _current_round_battle_history_is_ready()
var battle_history: Dictionary[int, BattleHistory] # Key=round_id, Value=BattleHystory

# ============================== Constant ==============================

# Key=<number of players still alive> | Value=<array of possible battle category combinations>
const BATTLES_COMBINATION_DIC = {
	2: [[Battle.BattleCategory.C2_PLAYERS_BATTLE]],
	3: [[Battle.BattleCategory.C3_PLAYERS_BATTLE]],
	4: [[Battle.BattleCategory.C2_PLAYERS_BATTLE, 
			Battle.BattleCategory.C2_PLAYERS_BATTLE],
		[Battle.BattleCategory.C4_PLAYERS_BATTLE]],
	5: [[Battle.BattleCategory.C2_PLAYERS_BATTLE, 
			Battle.BattleCategory.C3_PLAYERS_BATTLE]],
	6: [[Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C2_PLAYERS_BATTLE],
		[Battle.BattleCategory.C2_PLAYERS_BATTLE, 
			Battle.BattleCategory.C4_PLAYERS_BATTLE]],
	7: [[Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C3_PLAYERS_BATTLE],
		[Battle.BattleCategory.C4_PLAYERS_BATTLE,
			Battle.BattleCategory.C3_PLAYERS_BATTLE]],
	8: [[Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C2_PLAYERS_BATTLE,
			Battle.BattleCategory.C2_PLAYERS_BATTLE],
		[Battle.BattleCategory.C4_PLAYERS_BATTLE,
			Battle.BattleCategory.C4_PLAYERS_BATTLE]],
}

# ============================== Private variables ==============================

# [Server Only]
var _is_ready: bool = false
signal _battles_chosen()

# [Client only] Is emit when server has answered the local client request
signal _server_answered()

var battles: Dictionary[int, Battle] = {}

# ============================== Public functions ==============================

func get_current_round_battles() -> Array[Battle]:
	current_round += 1
	print("STARTING A NEW ROUND: ", current_round)
	battle_history[current_round] = BattleHistory.new()
	battle_history[current_round].round_id = current_round
	battles.clear()
	if multiplayer.is_server():
		_init_current_round_battles()
	else:
		_ask_current_round_battles.rpc_id(1, multiplayer.get_unique_id())
		await _server_answered
	
	return battles.values()


func register_battle_result(battle_id: int, winner_teams_order: Array[int]) -> void:
	print("register_battle_result()")
	var battle_result := BattleResult.new()
	battle_result.battle_id = battle_id
	battle_result.battle_type = battles[battle_id].battle_type
	
	for team_id in winner_teams_order:
		for player in battles[battle_id].players:
			if player.team == team_id:
				if not battle_result.players.has(team_id):
					battle_result.players[team_id] = [player]
				else:
					battle_result.players[team_id].append(player)
	
	battle_history[current_round].battle_results.append(battle_result)
	if battle_history[current_round].battle_results.size() == battles.size():
		_current_round_battle_history_is_ready.emit()


# [Server Only]
# Handle all changes affecting players at start of round: gold gain, change of damage, etc
func starting_round_player_changes() -> void:
	if current_round < 2 or not multiplayer.is_server():
		return
	var game_rules: GameRules = GameManager.game_rules
	for player_ in PlayerManager.players.values():
		var player: Player = player_
		var gold_stacks: int = clampi(player.gold/100, 0, game_rules.gold_stack_max)
		var gold_increase_economy: int = gold_stacks * game_rules.gold_earned_per_100_gold_stack
		var gold_increase_hp_lost: int = player.health_lost_since_last_round * game_rules.gold_earned_per_hp_lost
		var player_win_streak: int = clamp(player.win_streak, 0, game_rules.gold_earned_on_win_streak.size() - 1)
		var gold_increase_win_streak: int = game_rules.gold_earned_on_win_streak[player_win_streak]
		player.gold += game_rules.gold_earned_per_round + gold_increase_economy + gold_increase_hp_lost + gold_increase_win_streak


# [Server Only]
# Handle all changes affecting players at end of round: damage taken by loosing a fight
func ending_round_player_changes() -> void:
	if not multiplayer.is_server():
		return
	
	# Not all FightingArea reported their fight result yet (There is a race of signals)
	if battle_history[current_round].battle_results.size() != battles.size():
		await _current_round_battle_history_is_ready
	
	for battle_result in battle_history[current_round].battle_results:
		var players_by_team: Array[Array] = battle_result.players.values()
		var winners: Array = players_by_team[players_by_team.size() - 1]
		var loosers: Array = players_by_team[0]
		var winner_team_damage: int = 0
		for winner_ in winners:
			var winner: Player = winner_
			winner.win_streak += 1
			winner_team_damage += winner.damage
		for looser_ in loosers:
			var looser: Player = looser_
			looser.win_streak = 0
			print(looser.name, " takes ", winner_team_damage, "/", winners.size(), " damage !")
			looser.health -= winner_team_damage / winners.size()

# ============================== RPC - Ask/Answer current round battle ==============================

@rpc("any_peer", "call_remote")
func _ask_current_round_battles(peer_id: int) -> void:
	if not multiplayer.is_server():
		printerr("Only the server can answer the current round battles")
		return
	
	if not _is_ready:
		await _battles_chosen
	
	var serialized_battles: Array[Dictionary]
	for battle in battles.values():
		serialized_battles.append(battle.serialized())
	_anwser_current_round_battles.rpc_id(peer_id, serialized_battles)


@rpc("authority", "call_remote")
func _anwser_current_round_battles(serialized_battles: Array[Dictionary]) -> void:
	for serialized_battle in serialized_battles:
		var battle := Battle.new_from_serialized(serialized_battle)
		battles[battle.id] = battle
	_server_answered.emit()

# ============================== Private functions ==============================

# Get a random set of battles according to the alive players number
# Fill the battle with random players and sort them in team randomly
func _init_current_round_battles() -> void:
	var alive_players = PlayerManager.get_alive_players().duplicate()
	var battle_categories = _get_battle_categories(alive_players.size())
	
	# Construct the _battles array with all battle, fill them with players, assigned team to players
	var battle_id: int = 0
	for battle_category in battle_categories:
		var battle := Battle.new_from_category(battle_category)
		battle.fill_with_players(alive_players)
		battle.id = battle_id
		battles[battle.id] = battle
		battle_id += 1
	
	_is_ready = true
	_battles_chosen.emit()


# Get a random battle categories combination from a number of players alive
func _get_battle_categories(alive_players_number: int) -> Array:
	var battle_combinations: Array = BATTLES_COMBINATION_DIC[alive_players_number]
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var combination_id = rng.randi_range(0, battle_combinations.size() - 1)
	return battle_combinations[combination_id]



















 
