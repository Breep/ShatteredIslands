extends Node

var current_round: int

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

var _battles: Array[Battle]

# ============================== Public functions ==============================

func get_current_round_battles() -> Array[Battle]:
	if multiplayer.is_server():
		_init_current_round_battles()
	else:
		_ask_current_round_battles.rpc_id(1, multiplayer.get_unique_id())
		await _server_answered
	
	return _battles

# ============================== RPC - Ask/Answer current round battle ==============================

@rpc("any_peer", "call_remote")
func _ask_current_round_battles(peer_id: int) -> void:
	if not multiplayer.is_server():
		printerr("Only the server can answer the current round battles")
		return
	
	if not _is_ready:
		await _battles_chosen
	
	var serialized_battles: Array[Dictionary]
	for battle in _battles:
		serialized_battles.append(battle.serialized())
	_anwser_current_round_battles.rpc_id(peer_id, serialized_battles)


@rpc("authority", "call_remote")
func _anwser_current_round_battles(serialized_battles: Array[Dictionary]) -> void:
	for serialized_battle in serialized_battles:
		_battles.append(Battle.new_from_serialized(serialized_battle))
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
		battle_id += 1
		_battles.append(battle)
	
	_is_ready = true
	_battles_chosen.emit()


# Get a random battle categories combination from a number of players alive
func _get_battle_categories(alive_players_number: int) -> Array:
	var battle_combinations: Array = BATTLES_COMBINATION_DIC[alive_players_number]
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var combination_id = rng.randi_range(0, battle_combinations.size() - 1)
	return battle_combinations[combination_id]



















 
