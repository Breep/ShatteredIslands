extends Control

@export var _ui_all_families_portrait: UIAllFamiliesPortrait
@export var _hide_show_button: Button

@export var _families: Array[Family]

var _is_families_portrait_hidden: bool = false

func _ready() -> void:
	if _is_families_portrait_hidden:
		_ui_all_families_portrait.hide_families()
	else:
		_ui_all_families_portrait.show_families()
	_ui_all_families_portrait.init_portait_families(_families)

func _on_hide_show_button_pressed() -> void:
	if _is_families_portrait_hidden:
		_hide_show_button.text = "Hide"
		_is_families_portrait_hidden = false
		_ui_all_families_portrait.show_families()
	else:
		_hide_show_button.text = "Show"
		_is_families_portrait_hidden = true
		_ui_all_families_portrait.hide_families()
