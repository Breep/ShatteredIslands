extends Node

# ============================== Signals ==============================

signal player_added(peer_id: int)
signal player_removed(peer_id: int)

# ============================== Enum ==============================

enum SyncID {
	ROUND_SETUP,
	BUYING_PHASE,
	FIGHTING_PHASE,
}

enum JoinGameKeys {
	RESPONSE,
	REASON
}

# ============================== Constants ==============================

const PLAYER_SCENE: PackedScene = preload("res://07_Players/player.tscn")

# Bot names and their fake peer_id
const BOT_INFOS: Dictionary[int, String] = {
	-10: "Spide Ren'heure",
	-20: "Alex_Supertramp",
	-30: "Pwet",
	-40: "gooby",
	-50: "Meumeux",
	-60: "TheAFKKnight",
	-70: "Twiins",
	-80: "Xx_Slayer_xX",
	-90: "Josette",
	-100: "Zorro",
	-110: "Latika"
}

const MAX_PLAYERS: int = 8

# ============================== Public variables ==============================

var players: Dictionary[int, Player]

# ============================== Private variables ==============================

signal _join_server_answered()
var _join_server_has_answered: bool
var _join_server_response: bool
var _join_server_reason: String

# ============================== Node base functions ==============================

func _init() -> void:
	Verbose.debug("PLAYER MANAGER INIT", Verbose.Category.DEFAULT)

func _ready() -> void:
	player_removed.connect(_on_player_removed_sync_check)

# ============================== Public functions ==============================

func clear() -> void:
	for player in players.values():
		if is_instance_valid(player):
			player.queue_free()
	players.clear()

# ============================== Public getter ==============================

func get_local_player() -> Player:
	if not players.has(multiplayer.get_unique_id()):
		return null
	return players[multiplayer.get_unique_id()]


# En roguelite il n'y a plus de notion "mort/vivant via health PvP" : tout
# joueur dans la map est considéré actif tant que la run n'est pas finished.
func get_alive_players() -> Dictionary[int, Player]:
	return players


# Get all non bot players
func get_human_players() -> Dictionary[int, Player]:
	var human_players: Dictionary[int, Player]
	for player in players.values():
		if player.id > 0:
			human_players[player.id] = player
	return human_players


func join_game(peer_id: int, player_name: String) -> Dictionary:
	if multiplayer.is_server() and GameManager.game_type != GameManager.GameType.SOLO:
		Verbose.error("PlayerManager: Server can't be a player")
		return {JoinGameKeys.RESPONSE: false, JoinGameKeys.REASON: "Server can't be a player"}

	_ask_join_game.rpc_id(1, peer_id, player_name)
	if not _join_server_has_answered:
		await _join_server_answered

	_join_server_has_answered = false
	if _join_server_response == true:
		return {JoinGameKeys.RESPONSE: true, JoinGameKeys.REASON: "OK"}
	else:
		Verbose.error("PlayerManager: Can't join the game -> " + _join_server_reason)
		return {JoinGameKeys.RESPONSE: false, JoinGameKeys.REASON: _join_server_reason}


func kick_from_game(peer_id: int) -> void:
	_remove_player.rpc(peer_id)


func add_bot() -> void:
	var bot_infos := BOT_INFOS.duplicate()
	for player in players.values():
		if player.is_bot:
			bot_infos.erase(player.id)

	var bot_id = bot_infos.keys().pick_random()
	_add_player(BOT_INFOS[bot_id], bot_id, true)

# ============================== RPC - SYNC POINT ==============================

const SYNC_POINT_TIMEOUT: float = 15

signal __sync_point_resolved(sync_id: SyncID)
var __players_ready_for_sync: Dictionary[int, Dictionary] # Key=SyncID, Value=Dictionary[int(player_id), bool]

func sync_point(sync_id: SyncID) -> void:
	Verbose.debug("sync_point() | " + str(SyncID.keys()[sync_id]), Verbose.Category.NET)
	_client_ready.rpc_id(1, sync_id)

	if not _is_sync_resolved(sync_id):
		# Watchdog: force resolution after timeout (server only)
		var watchdog: SceneTreeTimer = get_tree().create_timer(SYNC_POINT_TIMEOUT)
		watchdog.timeout.connect(func():
			if not _is_sync_resolved(sync_id) and multiplayer.is_server():
				Verbose.warn("sync_point TIMEOUT for " + SyncID.keys()[sync_id] + " — forcing progression", Verbose.Category.NET)
				_all_clients_ready.rpc(sync_id)
		)
		# Wait for resolution (either all peers ready, disconnect auto-resolve, or timeout)
		while not _is_sync_resolved(sync_id):
			await __sync_point_resolved

	# Reset for next use
	__players_ready_for_sync.erase(sync_id)


func _is_sync_resolved(sync_id: SyncID) -> bool:
	if not __players_ready_for_sync.has(sync_id):
		return false
	var expected_ids: Array[int] = _get_expected_sync_player_ids()
	for player_id in expected_ids:
		if not __players_ready_for_sync[sync_id].has(player_id):
			return false
	return true


func _get_expected_sync_player_ids() -> Array[int]:
	var ids: Array[int]
	for player_id in get_human_players().keys():
		ids.append(player_id)
	return ids


@rpc("any_peer", "call_local")
func _client_ready(sync_id: SyncID) -> void:
	if not multiplayer.is_server():
		return

	var peer_id: int = multiplayer.get_remote_sender_id()
	Verbose.trace("_client_ready() | " + str(SyncID.keys()[sync_id]) + " | peer=" + str(peer_id), Verbose.Category.NET)

	if not __players_ready_for_sync.has(sync_id):
		__players_ready_for_sync[sync_id] = {}
	__players_ready_for_sync[sync_id][peer_id] = true

	if _is_sync_resolved(sync_id):
		_all_clients_ready.rpc(sync_id)


@rpc("authority", "call_local")
func _all_clients_ready(sync_id: SyncID) -> void:
	Verbose.trace("_all_clients_ready() | " + str(SyncID.keys()[sync_id]), Verbose.Category.NET)
	# Mark all expected players as ready to resolve the await
	var expected_ids: Array[int] = _get_expected_sync_player_ids()
	if not __players_ready_for_sync.has(sync_id):
		__players_ready_for_sync[sync_id] = {}
	for player_id in expected_ids:
		__players_ready_for_sync[sync_id][player_id] = true
	__sync_point_resolved.emit(sync_id)


func _on_player_removed_sync_check(peer_id: int) -> void:
	# When a player disconnects, check if any pending sync_point is now resolved
	for sync_id in __players_ready_for_sync.keys():
		if _is_sync_resolved(sync_id) and multiplayer.is_server():
			Verbose.debug("sync_point auto-resolved after player " + str(peer_id) + " disconnect | " + SyncID.keys()[sync_id], Verbose.Category.NET)
			_all_clients_ready.rpc(sync_id)

# ============================== RPC - Ask/Answer Join game ==============================

@rpc("any_peer", "call_local")
func _ask_join_game(peer_id: int, player_name: String) -> void:
	Verbose.trace("_ask_join_game() | " + str(peer_id) + " | " + player_name, Verbose.Category.PLAYER_MANAGER)
	if not multiplayer.is_server():
		printerr("PlayerManager: Only the server should be asked to join the game")
		return

	if players.size() >= MAX_PLAYERS:
		printerr("[id:", multiplayer.get_unique_id(), "] Too many players")
		_answer_join_game.rpc_id(peer_id, false, "Too many players")
		return

	for player in players.values():
		if player.player_name == player_name:
			printerr("[id:", multiplayer.get_unique_id(), "] A player with the same name has already joined")
			_answer_join_game.rpc_id(peer_id, false, "A player with the same name has already joined")
			return
		elif player.id == peer_id:
			printerr("[id:", multiplayer.get_unique_id(), "] Player already exist")
			_answer_join_game.rpc_id(peer_id, false, "Player already in the game")
			return

	_answer_join_game.rpc_id(peer_id, true, "OK")
	_add_player(player_name, peer_id, false)


@rpc("authority", "call_local")
func _answer_join_game(response: int, reason: String) -> void:
	Verbose.trace("_answer_join_game() | " + str(response) + " | " + reason, Verbose.Category.PLAYER_MANAGER)
	_join_server_response = response
	_join_server_reason = reason
	_join_server_has_answered = true
	_join_server_answered.emit()

# ============================== Private functions ==============================

# Add a player to the list of players
# Server creates the Player node with full data, then tells clients to create a matching node.
# The MultiplayerSynchronizer on each Player node handles property sync automatically.
@rpc("authority", "call_remote")
func _add_player(player_name: String, id: int, is_bot: bool) -> void:
	Verbose.trace("_add_player() | " + player_name + " | id=" + str(id) + " | " + str(is_bot), Verbose.Category.PLAYER_MANAGER)

	if players.has(id) or players.size() >= MAX_PLAYERS:
		return

	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.init_player()
	new_player.name = "Player_" + str(id)
	new_player.player_name = player_name
	new_player.id = id
	new_player.is_bot = is_bot

	players[id] = new_player
	add_child(new_player)
	new_player.setup_components()
	player_added.emit(id)

	# Server broadcasts to all clients so they create matching nodes
	if multiplayer.is_server():
		for player: Player in players.values():
			_add_player.rpc(player.player_name, player.id, player.is_bot)


@rpc("authority", "call_local")
func _remove_player(peer_id: int) -> void:
	Verbose.trace("_remove_player() | " + str(peer_id), Verbose.Category.PLAYER_MANAGER)
	if players.has(peer_id):
		var player: Player = players[peer_id]
		if is_instance_valid(player):
			player.queue_free()
		players.erase(peer_id)
	player_removed.emit(peer_id)


