class_name UIMainMenu
extends Control

@export_group("Local Nodes")
@export var _play_button: Button

@onready var _play_menu: UIPlayMenu = %PlayMenu
@onready var _game_settings: UIGameSettings = %GameSettings

func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed() -> void:
	_play_menu.show()


func _on_settings_button_pressed() -> void:
	_game_settings.show()
