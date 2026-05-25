class_name UIPauseMenu
extends Control

## Pause/escape menu. Reusable in both in-game and main-menu contexts:
## hide Resume / Settings / Main Menu entries via exports when irrelevant.
## Hidden Settings/Main Menu entries are replaced by placeholder TextureRects
## so the panel proportions stay consistent. Placeholders are reset to hidden
## when the menu closes.

# ============================== Signals ==============================

signal settings_requested

# ============================== Enums ==============================

enum PauseState {
	UNDEF,
	OPTION,
	MAIN_MENU,
	QUIT,
}

# ============================== Export ==============================

@export var show_resume: bool = true
@export var show_settings: bool = true
@export var show_back_to_main_menu: bool = true

# ============================== Local nodes ==============================

@onready var _confirm_panel: Panel = %ConfirmPanel
@onready var _confirm_label: Label = %ConfirmLabel
@onready var _resume_button: Button = %ResumeButton
@onready var _option_button: Button = %OptionButton
@onready var _main_menu_button: Button = %MainMenuButton
@onready var _settings_placeholder: TextureRect = %TextureRect
@onready var _main_menu_placeholder: TextureRect = %TextureRect2

# ============================== Private variables ==============================

var _pause_state: PauseState

# ============================== Node base functions ==============================

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_resume_button.visible = show_resume
	_option_button.visible = show_settings
	_main_menu_button.visible = show_back_to_main_menu
	hide()


func _on_visibility_changed() -> void:
	if not visible:
		_settings_placeholder.visible = false
		_main_menu_placeholder.visible = false
		return
	Events.ui_window_opened.emit()
	_settings_placeholder.visible = not show_settings
	_main_menu_placeholder.visible = not show_back_to_main_menu

# ============================== Private functions ==============================

# ============================== Callbacks ==============================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_confirm_panel.hide()
		_pause_state = PauseState.UNDEF
		if not is_visible_in_tree(): show()
		else: hide()


func _on_resume_button_pressed() -> void:
	hide()


func _on_option_button_pressed() -> void:
	_pause_state = PauseState.OPTION
	settings_requested.emit()


func _on_main_menu_button_pressed() -> void:
	_pause_state = PauseState.MAIN_MENU
	_confirm_panel.show()
	_confirm_label.text = "Go back to main menu ?"


func _on_quit_button_pressed() -> void:
	_pause_state = PauseState.QUIT
	_confirm_panel.show()
	_confirm_label.text = "Quit the game ?"


func _on_yes_button_pressed() -> void:
	match _pause_state:
		PauseState.MAIN_MENU:
			get_tree().change_scene_to_file("res://Game/MainMenu/main_menu.tscn")
		PauseState.QUIT:
			get_tree().quit()


func _on_no_button_pressed() -> void:
	_confirm_panel.hide()
	_pause_state = PauseState.UNDEF
