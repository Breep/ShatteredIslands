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
	pass


func _on_peer_disconnected(id):
	pass


func _on_player_manager_player_added(peer_id: int) -> void:
	if not multiplayer.is_server(): return
	_add_connected_player_line(peer_id)
