extends Node

# ============================== Enums ==============================

enum PeerType {
	SERVER,
	CLIENT,
}

# ============================== Private variables ==============================

const DEFAULT_SERVER_IP = "127.0.0.1"
const DEFAULT_SERVER_PORT = 4242

# ============================== Node base function ==============================

func _ready() -> void:
	if "server" in OS.get_cmdline_args(): #SERVER
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

func _start_server(port: int) -> void:
	print("MultiplayerManager: Starting server - ", port)
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
	print("MultiplayerManager: ", id, " connected !")


func _on_peer_disconnected(id):
	if not multiplayer.is_server(): return
	print("MultiplayerManager: ", id, " disconnected !")
	PlayerManager.kick_from_game(id)


func _on_connected_to_server():
	if multiplayer.is_server(): return
	print("MultiplayerManager: [", multiplayer.get_unique_id(), "] Connected to server !")


func _on_connection_failed():
	printerr("MultiplayerManager: Connection failed !")
