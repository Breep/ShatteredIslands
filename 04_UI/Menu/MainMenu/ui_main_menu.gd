class_name UIMainMenu
extends Control

@export_group("Local Nodes")
@export var _play_button: Button
@export var _tutorial_check_box: CheckBox

@onready var _play_menu: UIPlayMenu = %PlayMenu
@onready var _game_settings: UIGameSettings = %GameSettings

func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)
	_tutorial_check_box.button_pressed = Settings.is_tutorial_enabled()
	_tutorial_check_box.toggled.connect(_on_tutorial_check_box_toggled)


func _on_play_button_pressed() -> void:
	_play_menu.show()


func _on_settings_button_pressed() -> void:
	_game_settings.show()
func _on_tutorial_check_box_toggled(toggled_on: bool) -> void:
	Settings.set_tutorial_enabled(toggled_on)
