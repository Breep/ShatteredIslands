class_name UIPlayerInfoTemplate
extends HBoxContainer

signal kick_button_pressed(peer_id: int)

var _player_id: int
var _player_name: String


@onready var _player_name_label: Label = %PlayerName
@onready var _player_id_label: Label = %PlayerId

func _ready() -> void:
	_player_name_label.text = _player_name
	_player_id_label.text = str(_player_id)

func update_info(player_id: int, player_name: String) -> void:
	_player_id = player_id
	_player_name = player_name

func _on_button_pressed() -> void:
	kick_button_pressed.emit(_player_id)
	queue_free()
