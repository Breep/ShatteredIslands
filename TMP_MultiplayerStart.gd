extends Control

@export var address = "127.0.0.1"
@export var port = 4242

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected_cb)
	multiplayer.peer_disconnected.connect(_peer_disconnected_cb)
	multiplayer.connected_to_server.connect(_connect_to_server_cb)
	multiplayer.connection_failed.connect(_connection_failed_cb)
	pass

# ============================================

func _peer_connected_cb(id):
	print("Player", id, " connected !")

func _peer_disconnected_cb(id):
	print("Player", id, " disconnected !")

func _connect_to_server_cb():
	print("Connected to server !")

func _connection_failed_cb():
	printerr("Connection failed !")

# ============================================

func _on_host_button_pressed() -> void:
	_hostGame()

func _on_start_button_pressed() -> void:
	pass # Replace with function body.

func _on_join_button_pressed() -> void:
	_joinGame()

# ============================================

func _hostGame():
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 8)
	if error != OK:
		printerr("Cannot host: ", str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")

func _joinGame():
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		printerr("Cannot host: ", str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Server joined")
