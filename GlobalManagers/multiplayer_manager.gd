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
#server --headless --auto-start=3 --expected_clients=1
func _ready() -> void:
	auto_start_time = float(_get_cmd_arg("auto-start", "0"))
	expected_clients = int(_get_cmd_arg("expected_clients", "1"))
	
	
	if "--server" in OS.get_cmdline_args(): #SERVER
		_start_server(DEFAULT_SERVER_PORT)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	else: #CLIENT ONLY
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)

# ============================== Public function ==============================

func try_connect(ip: String, port: int) -> bool:
	return _add_peer(PeerType.CLIENT, port, ip)

# ============================== Private function ==============================

func _check_args(args: PackedStringArray) -> void:
	for arg in args:
		print(arg)
		#match arg:
			#"--headless":
				#print("Lanching headless server")
			#"--"

func _get_cmd_arg(key: String, default: String = "") -> String:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--" + key + "="):
			return arg.get_slice("=", 1)
	return default


func _start_server(port: int) -> void:
	print("[SERVER_DEBUG] MultiplayerManager: Starting server - ", port)
	print("[SERVER_DEBUG] MultiplayerManager: Expecting ", expected_clients, " clients")
	print("[SERVER_DEBUG] MultiplayerManager: Auto starting game after ", auto_start_time, "s")
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
		printerr("MultiplayerManager: Cannot add peer: ", str(error))
		return false
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	return true

# ============================== Callbacks ==============================

func _on_peer_connected(id):
	if not multiplayer.is_server(): return
	_clients_number += 1
	print("[SERVER_DEBUG], MultiplayerManager: A client [", id, "] connected (", _clients_number, "/", expected_clients, ")")
	if _clients_number >= expected_clients:
		print("[SERVER_DEBUG] MultiplayerManager: All clients are connected, starting the countdown (", auto_start_time, ")")
		Utils.create_one_shot_timer(self, auto_start_time, _on_auto_start_timeout, true)


func _on_peer_disconnected(id):
	if not multiplayer.is_server(): return
	print("MultiplayerManager: ", id, " disconnected !")
	PlayerManager.kick_from_game(id)


func _on_connected_to_server():
	if multiplayer.is_server(): return


func _on_connection_failed():
	printerr("MultiplayerManager: Connection failed !")


func _on_auto_start_timeout() -> void:
	while PlayerManager.players.size() < PlayerManager.MAX_PLAYERS:
		PlayerManager.add_bot()
	GameManager.start_game.rpc()
