class_name UIPlayMenu
extends Control

@onready var _back_button: Button = %BackButton
@onready var _join_button: Button = %JoinButton
@onready var _start_solo_button: Button = %StartSoloButton

@onready var _player_name_edit: LineEdit = %PlayerNameEdit
@onready var _server_ip_edit: LineEdit = %ServerIPEdit
@onready var _server_port_edit: LineEdit = %ServerPortEdit

@onready var _client_message: Label = %ClientMessage

@onready var _sub_play_menu: MarginContainer = %SubPlayMenu

func _ready() -> void:
	hide()
	_back_button.pressed.connect(_on_back_button_pressed)
	_join_button.pressed.connect(_on_join_button_pressed)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _on_back_button_pressed() -> void:
	hide()


func _on_join_button_pressed() -> void:
	var ip: String = _server_ip_edit.text
	var port: int = int(_server_port_edit.text)
	MultiplayerManager.try_connect(ip, port)


func _on_connected_to_server():
	print("PlayMenu: [", multiplayer.get_unique_id(), "] Connected to server !")
	_client_message.show()
	_sub_play_menu.hide()
	
	_client_message.add_theme_color_override("font_color", Color(0, 0, 0))
	_client_message.text = "Asking the SERVER to join the game"
	
	await get_tree().create_timer(1.0).timeout # TODO remove
	
	var res = await PlayerManager.join_game(multiplayer.get_unique_id(), _player_name_edit.text)
	if res[PlayerManager.JoinGameKeys.RESPONSE] == true:
		print("PlayMenu: [", multiplayer.get_unique_id(), "] Joined the game !")
		_client_message.add_theme_color_override("font_color", Color(0, 0, 0))
		_client_message.text = "Waiting for SERVER to start the game"
	else:
		printerr("[", multiplayer.get_unique_id(), "] Can't join the game ! -> ", res[PlayerManager.JoinGameKeys.REASON])
		_client_message.add_theme_color_override("font_color", Color(1, 0, 0))
		_client_message.text = res[PlayerManager.JoinGameKeys.REASON]
		await get_tree().create_timer(3.0).timeout


func _on_connection_failed() -> void:
	_sub_play_menu.show()
	_client_message.hide()
