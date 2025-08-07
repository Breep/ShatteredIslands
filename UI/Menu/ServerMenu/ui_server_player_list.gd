class_name UIServerPlayerList
extends Control

@onready var _server_panels: Control = %ServerPanels
@onready var _players_list: Control = %PlayersList

@onready var _player_info_template: HBoxContainer = %PlayerInfoTemplate

# ============================================

func _ready() -> void:
	PlayerManager.player_added.connect(_on_player_manager_player_added)
	
	for child in _players_list.get_children():
		child.hide()
	
	#SERVER ONLY
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# ============================================

func _add_connected_player_line(peer_id: int) -> void:
	if not multiplayer.is_server(): return
	var new_line: UIPlayerInfoTemplate = _player_info_template.duplicate()
	new_line.update_info(peer_id, PlayerManager.players[peer_id].name)
	new_line.show()
	new_line.kick_button_pressed.connect(_on_new_line_kick_button_pressed)
	_players_list.add_child(new_line)


func _on_new_line_kick_button_pressed(peer_id: int) -> void:
	PlayerManager.kick_from_game(peer_id)

# ============================================

func _on_start_button_pressed() -> void:
	GameManager.start_game.rpc()


func _on_add_bot_button_pressed() -> void:
	while PlayerManager.players.size() < PlayerManager.MAX_PLAYERS:
		PlayerManager.add_bot()

# ============================================

func _on_peer_connected(id):
	if multiplayer.is_server():
		print("Player", id, " connected !")


func _on_peer_disconnected(id):
	print("Player", id, " disconnected !")
	if multiplayer.is_server():
		PlayerManager.kick_from_game(id)


#func _on_connected_to_server():
	#print("[", multiplayer.get_unique_id(), "] Connected to server !")
	#_client_message.add_theme_color_override("font_color", Color(0, 0, 0))
	#_client_message.text = "Asking the SERVER to join the game"
	#
	#var res = await PlayerManager.join_game(multiplayer.get_unique_id(), _player_name_edit.text)
	#if res[PlayerManager.JoinGameKeys.RESPONSE] == true:
		#print("[", multiplayer.get_unique_id(), "] Join the game !")
		#_client_message.add_theme_color_override("font_color", Color(0, 0, 0))
		#_client_message.text = "Waiting for SERVER to start the game"
	#else:
		#printerr("[", multiplayer.get_unique_id(), "] Can't join the game ! -> ", res[PlayerManager.JoinGameKeys.REASON])
		#_client_message.add_theme_color_override("font_color", Color(1, 0, 0))
		#_client_message.text = res[PlayerManager.JoinGameKeys.REASON]
		#await get_tree().create_timer(3.0).timeout
		#_first_selection.show()
		#_client_message.hide()


func _on_player_manager_player_added(peer_id: int) -> void:
	if not multiplayer.is_server(): return
	_add_connected_player_line(peer_id)
