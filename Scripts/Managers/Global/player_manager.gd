extends Node

# Bot names and their fake peer_id
const BOT_INFOS: Dictionary [int, String] = {
	-1: "Spide Ren'heure",
	-2: "Alex_Supertramp",
	-3: "Pwet",
	-4: "gooby",
	-5: "Meumeux",
	-6: "TheAFKKnight",
	-7: "CritsMcGee",
	-8: "Xx_Slayer_xX",
	-9: "GoldHoarder",
	-10: "Zorro"
}

enum JoinGameKeys {
	RESPONSE,
	REASON
}

const MAX_PLAYERS: int = 8

var players: Dictionary[int, Player]

signal player_added(peer_id: int)
signal player_removed(peer_id: int)

signal _join_server_answered()
var _join_server_response: bool
var _join_server_reason: String

# ============================== Public functions ==============================

func get_local_player() -> Player:
	if not players.has(multiplayer.get_unique_id()):
		printerr(" No local player for player_id=", multiplayer.get_unique_id())
		return null
	return players[multiplayer.get_unique_id()]


func get_alive_players() -> Dictionary:
	var alive_players: Dictionary
	for player in players.values():
		if player.health > 0:
			alive_players[player.id] = player
	return alive_players


func join_game(peer_id: int, player_name: String) -> Dictionary:
	if multiplayer.is_server():
		printerr("PlayerManager: Server can't be a player")
		return {JoinGameKeys.RESPONSE: false, JoinGameKeys.REASON: "Server can't be a player"}
	
	_ask_join_game.rpc_id(1, peer_id, player_name)
	await _join_server_answered
	
	if _join_server_response == true:
		return {JoinGameKeys.RESPONSE: true, JoinGameKeys.REASON: "OK"}
	else:
		printerr("PlayerManager: Can't join the game -> ", _join_server_reason)
		return {JoinGameKeys.RESPONSE: false, JoinGameKeys.REASON: _join_server_reason}


func kick_from_game(peer_id: int) -> void:
	_remove_player.rpc(peer_id)


func add_bot() -> void:
	var bot_infos := BOT_INFOS.duplicate()
	for player in players.values():
		if player.is_bot:
			bot_infos.erase(player.id)
	
	var bot_id = bot_infos.keys().pick_random()
	_add_player(BOT_INFOS[bot_id], bot_id, true, {})


signal __all_players_syncronized()
var __number_of_players_syncronized: int
func sync_point() -> void:
	print("       DEBUG sync_point() ", multiplayer.get_peers().size())
	if not multiplayer.is_server():
		_client_ready.rpc_id(1, multiplayer.get_unique_id())
	elif multiplayer.is_server() and multiplayer.get_peers().size() == 0:
		return
	
	await __all_players_syncronized
	__number_of_players_syncronized = 0


@rpc("any_peer", "call_remote")
func _client_ready(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	__number_of_players_syncronized += 1
	if __number_of_players_syncronized >= multiplayer.get_peers().size():
		_all_clients_ready.rpc()


@rpc("authority", "call_local")
func _all_clients_ready() -> void:
	__all_players_syncronized.emit()

# ============================== RPC - Ask/Answer Join game ==============================

@rpc("any_peer", "call_remote")
func _ask_join_game(peer_id: int, player_name: String) -> void:
	if not multiplayer.is_server():
		printerr("PlayerManager: Only the server should be asked to join the game")
		return
	
	if players.size() >= MAX_PLAYERS:
		printerr("[id:", multiplayer.get_unique_id(),"] Too many players")
		_answer_join_game.rpc_id(peer_id, false, "Too many players")
		return
	
	for player in players.values():
		if player.name == player_name:
			printerr("[id:", multiplayer.get_unique_id(),"] A player with the same name has already joined")
			_answer_join_game.rpc_id(peer_id, false, "A player with the same name has already joined")
			return
		elif player.id == peer_id:
			printerr("[id:", multiplayer.get_unique_id(),"] Player already exist")
			_answer_join_game.rpc_id(peer_id, false, "Player already in the game")
			return
	
	_answer_join_game.rpc_id(peer_id, true, "OK")
	_add_player(player_name, peer_id, false, {})


@rpc("authority", "call_remote")
func _answer_join_game(response: int, reason: String) -> void:
	_join_server_response = response
	_join_server_reason = reason
	_join_server_answered.emit()

# ============================== Private functions ==============================

# Add a player to the list of players
# If this is called on the server, the server will transmit this to every other players
# TODO Improve this so it only send not known players to players
@rpc("authority", "call_remote")
func _add_player(player_name: String, id: int, is_bot: bool, serialized_player: Dictionary) -> void:
	print("[id:", multiplayer.get_unique_id(),"] Adding player: ", player_name, " of multiplayer id:", id, " in my players list")
	
	if players.has(id) or players.size() >= MAX_PLAYERS:
		return
	
	if multiplayer.is_server():
		var new_player := Player.new()
		new_player.name = player_name
		new_player.id = id
		new_player.is_bot = is_bot
		new_player.damage = 5
		new_player.gold = 500
		new_player.health = 30
		_connect_to_signals(new_player)
		
		players[id] = new_player
	else:
		players[id] = Player.new_from_serialized(serialized_player)
	
	player_added.emit(id)
	
	if multiplayer.is_server():
		for player in players.values():
			_add_player.rpc(player.name, player.id, player.is_bot, player.serialized())


@rpc("authority", "call_local")
func _remove_player(peer_id: int) -> void:
	player_removed.emit(peer_id)
	players.erase(peer_id)


func _connect_to_signals(player: Player) -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.max_health_changed.connect(_on_player_max_health_changed)
	player.damage_changed.connect(_on_player_damage_changed)
	player.hero_changed.connect(_on_player_hero_changed)
	player.gold_changed.connect(_on_player_gold_changed)


func _on_player_health_changed(player: Player, _unused) -> void:
	_sync_player.rpc(player.serialized())

func _on_player_max_health_changed(player: Player, _unused) -> void:
	_sync_player.rpc(player.serialized())

func _on_player_damage_changed(player: Player, _unused) -> void:
	_sync_player.rpc(player.serialized())

func _on_player_hero_changed(player: Player, _unused) -> void:
	_sync_player.rpc(player.serialized())

func _on_player_gold_changed(player: Player, _unused) -> void:
	_sync_player.rpc(player.serialized())

@rpc("authority", "call_remote")
func _sync_player(serialized_player: Dictionary) -> void:
	var player: Player = players[serialized_player[Player.SerializedField.ID]]
	player.update_from_serialized(serialized_player)



















 
