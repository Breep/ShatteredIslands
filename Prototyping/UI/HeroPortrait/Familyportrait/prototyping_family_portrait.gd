extends Control

@export var _ui_all_families_portrait: UIAllFamiliesPortrait
@export var _hide_show_button: Button

var _is_families_portrait_hidden: bool = true

func _ready() -> void:
	pass

func _on_hide_show_button_pressed() -> void:
	if _is_families_portrait_hidden:
		_hide_show_button.text = "Hide"
		_is_families_portrait_hidden = false
		_ui_all_families_portrait.show_families()
	else:
		_hide_show_button.text = "Show"
		_is_families_portrait_hidden = true
		_ui_all_families_portrait.hide_families()
