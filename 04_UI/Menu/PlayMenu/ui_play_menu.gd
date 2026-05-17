class_name UIPlayMenu
extends Control

@onready var _player_name_edit: LineEdit = %PlayerNameEdit
@onready var _server_ip_edit: LineEdit = %ServerIPEdit
@onready var _server_port_edit: LineEdit = %ServerPortEdit

@onready var _client_message: Label = %ClientMessage

@onready var _sub_play_menu: MarginContainer = %SubPlayMenu

func _ready() -> void:
	hide()

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _on_join_button_pressed() -> void:
	var ip: String = _server_ip_edit.text
	var port: int = int(_server_port_edit.text)
	MultiplayerManager.try_connect(ip, port)


func _on_connected_to_server():
	Verbose.debug("PlayMenu: [" + str(multiplayer.get_unique_id()) + "] Connected to server !")
	_client_message.show()
	_sub_play_menu.hide()
	
	_client_message.add_theme_color_override("font_color", Color(1, 1, 1))
	_client_message.text = "Asking the SERVER to join the game"
	
	var res = await PlayerManager.join_game(multiplayer.get_unique_id(), _player_name_edit.text)
	if res[PlayerManager.JoinGameKeys.RESPONSE] == true:
		Verbose.info("PlayMenu: [" + str(multiplayer.get_unique_id()) + "] Joined the game !")
		_client_message.text = "Waiting for SERVER to start the game"
	else:
		Verbose.error("[" + str(multiplayer.get_unique_id()) + "] Can't join the game ! -> " + res[PlayerManager.JoinGameKeys.REASON])
		_client_message.add_theme_color_override("font_color", Color(1, 0, 0))
		_client_message.text = res[PlayerManager.JoinGameKeys.REASON]


func _on_connection_failed() -> void:
	_sub_play_menu.show()
	_client_message.hide()


func _on_close_button_pressed() -> void:
	hide()


func _on_start_solo_button_pressed() -> void:
	GameManager.start_solo_game()


func _on_start_run_button_pressed() -> void:
	GameManager.start_solo_run()
