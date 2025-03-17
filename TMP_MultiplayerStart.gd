extends Control

enum PeerType {
	SERVER,
	CLIENT,
}

@export var address = "127.0.0.1"
@export var port = 4242

@onready var name_edit: LineEdit = %NameEdit

# ============================================

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	name_edit.text = "Breep" + str(rng.randi_range(0, 1000))
	pass

# ============================================

func _on_peer_connected(id):
	if multiplayer.is_server():
		print("Player", id, " connected !")


func _on_peer_disconnected(id):
	print("Player", id, " disconnected !")


func _on_connected_to_server():
	PlayerManager.add_player.rpc_id(1, name_edit.text, multiplayer.get_unique_id())
	print("Connected to server !")


func _on_connection_failed():
	printerr("Connection failed !")


# ============================================

func _on_host_button_pressed() -> void:
	_addPeer(PeerType.SERVER)
	$CenterContainer.hide()
	$ReadyButton.hide()
	$breakpoint.hide()


func _on_start_button_pressed() -> void:
	GameManager.start_game.rpc()


func _on_join_button_pressed() -> void:
	_addPeer(PeerType.CLIENT)




func _on_ready_button_toggled(toggled_on: bool) -> void:
	PlayerManager.set_ready.rpc(multiplayer.get_unique_id(), toggled_on)


# ============================================

func _addPeer(peerType: PeerType):
	var peer := ENetMultiplayerPeer.new()
	var error = ERR_BUG
	if peerType == PeerType.SERVER:
		error = peer.create_server(port, 8)
	elif peerType == PeerType.CLIENT:
		error = peer.create_client(address, port)
	
	if error != OK:
		printerr("Cannot host: ", str(error))
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_breakpoint_pressed() -> void:
	print("Breakpoint here")
	pass # Replace with function body.
