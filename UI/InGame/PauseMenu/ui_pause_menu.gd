class_name UIPauseMenu
extends Control

# ============================== Enums ==============================

enum PauseState {
	UNDEF,
	OPTION,
	MAIN_MENU,
	QUIT,
}

# ============================== Local nodes ==============================

@onready var _confirm_panel: Panel = %ConfirmPanel
@onready var _confirm_label: Label = %ConfirmLabel

# ============================== Private variables ==============================

var _pause_state: PauseState

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()

# ============================== Private functions ==============================

# ============================== Callbacks ==============================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_confirm_panel.hide()
		_pause_state = PauseState.UNDEF
		if not is_visible_in_tree(): show()
		else: hide()


func _on_resume_button_pressed() -> void:
	hide()


func _on_option_button_pressed() -> void:
	_pause_state = PauseState.OPTION


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
