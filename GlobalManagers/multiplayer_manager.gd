extends Node

# ============================== Enums ==============================

enum PeerType {
	SERVER,
	CLIENT,
}

# ============================== Private variables ==============================

const DEFAULT_SERVER_IP = "127.0.0.1"
const DEFAULT_SERVER_PORT = 4242

var auto_start_time: float = 3.0
var auto_start_activated: bool = true
var expected_clients: int = 1

var _clients_number: int = 0

# ============================== Node base function ==============================
func _ready() -> void:
	if "--prototyping" in OS.get_cmdline_args():
		return

	auto_start_time = float(_get_cmd_arg("auto-start", "0"))
	expected_clients = int(_get_cmd_arg("expected-clients", "1"))
	
	Verbose.info("Starting multiplayer manager", Verbose.Category.NET)
	
	if "--server" in OS.get_cmdline_args(): # SERVER
		_start_server(DEFAULT_SERVER_PORT)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	else: # CLIENT ONLY
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)

# ============================== Public function ==============================

func try_connect(ip: String, port: int) -> bool:
	return _add_peer(PeerType.CLIENT, port, ip)

# ============================== Private function ==============================

func _get_cmd_arg(key: String, default: String = "") -> String:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--" + key + "="):
			return arg.get_slice("=", 1)
	return default


func _start_server(port: int) -> void:
	Verbose.info("MultiplayerManager: Starting , server - " + str(port), Verbose.Category.NET)
	Verbose.info("MultiplayerManager: Expecting " + str(expected_clients) + " clients", Verbose.Category.NET)
	Verbose.info("MultiplayerManager: Auto starting game after " + str(auto_start_time) + "s", Verbose.Category.NET)
	_add_peer(PeerType.SERVER, port)


func _add_peer(peerType: PeerType, port: int, ip: String = "") -> bool:
	var peer := ENetMultiplayerPeer.new()
	var error = ERR_BUG
	if peerType == PeerType.SERVER:
		error = peer.create_server(port, 8)
	elif peerType == PeerType.CLIENT:
		var address = DEFAULT_SERVER_IP if ip.is_empty() else ip
		error = peer.create_client(address, port)
	
	if error != OK:
		Verbose.error("MultiplayerManager: Cannot add peer: " + str(error), Verbose.Category.NET)
		return false
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	return true

# ============================== Callbacks ==============================

func _on_peer_connected(id: int) -> void:
	_clients_number += 1
	Verbose.info("MultiplayerManager: A client [" + str(id) + "] connected (" + str(_clients_number) + "/" + str(expected_clients) + ")", Verbose.Category.NET)
	if _clients_number >= expected_clients:
		Verbose.info("MultiplayerManager: All clients are connected, starting the countdown (" + str(auto_start_time) + ")", Verbose.Category.NET)
		Utils.create_one_shot_timer(self, auto_start_time, _on_auto_start_timeout, true)


func _on_peer_disconnected(id: int) -> void:
	Verbose.info(str(id) + " disconnected !", Verbose.Category.NET)
	PlayerManager.kick_from_game(id)
	if PlayerManager.get_human_players().is_empty():
		Verbose.warn("No more human in my game -> SHUTTING DOWN !", Verbose.Category.NET)
		get_tree().quit()


func _on_connected_to_server() -> void:
	Verbose.info("Connected to server", Verbose.Category.NET)
	if multiplayer.is_server(): return


func _on_connection_failed():
	Verbose.info("Connection failed !", Verbose.Category.NET)


func _on_auto_start_timeout() -> void:
	Verbose.debug("Starting the game !", Verbose.Category.NET)
	while PlayerManager.players.size() < PlayerManager.MAX_PLAYERS:
		PlayerManager.add_bot()
	GameManager.start_game.rpc()
