class_name UIPlayMenu
extends Control

@onready var _back_button: Button = %BackButton
@onready var _join_button: Button = %JoinButton
@onready var _start_solo_button: Button = %StartSoloButton

@onready var _player_name_edit: LineEdit = %PlayerNameEdit
@onready var _server_ip_edit: LineEdit = %ServerIPEdit
@onready var _server_port_edit: LineEdit = %ServerPortEdit1

func _ready() -> void:
	hide()
	_back_button.pressed.connect(_on_back_button_pressed)


func _on_back_button_pressed() -> void:
	hide()
