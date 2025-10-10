class_name UIHeroPortrait
extends Control

# ============================== Configuration ==============================

@export_group("Effects Configuration")
@export var _effect_duration: float = 0.4

# ============================== Local nodes ==============================

@onready var _ui_all_families_portrait: UIAllFamiliesPortrait = %UIAllFamiliesPortrait
@onready var _ui_in_game_player_profile: UIInGamePlayerViewer = %InGamePlayerProfile
@onready var _minimize_button: TextureButton = %MinimizeButton

# ============================== Private variables ==============================

var _is_active: bool = false
var _panel_minimized: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	_minimize_button.hide()

# ============================== Private functions ==============================

func _activate() -> void:
	_ui_all_families_portrait.show_families()
	_ui_in_game_player_profile.show_panel()
	_show_minimize_button()
	_is_active = true
	_panel_minimized = false

func _deactivate() -> void:
	_ui_all_families_portrait.hide_families()
	_ui_in_game_player_profile.hide_panel()
	_hide_minimize_button()
	_is_active = false
	_panel_minimized = true

func _minimize_profile() -> void:
	_ui_in_game_player_profile.hide_panel()
	_panel_minimized = true


func _maximize_profile() -> void:
	_ui_in_game_player_profile.show_panel()
	_panel_minimized = false


func _show_minimize_button() -> void:
	_minimize_button.show()
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_minimize_button, "modulate:a", 1.0, _effect_duration).from(0.0)
	tw.parallel().tween_property(_minimize_button, "scale", Vector2.ONE, _effect_duration).from(Vector2(0.9, 0.9))


func _hide_minimize_button() -> void:
	_minimize_button.hide()
	_minimize_button.modulate.a = 0.0
	_minimize_button.scale = Vector2(0.9, 0.9)


func _on_hex_portrait_button_pressed(self_ref: HexButton) -> void:
	if _is_active:
		_deactivate()
	else:
		_activate()

# ============================== Callbacks ==============================

func _on_minimize_button_pressed() -> void:
	if _panel_minimized:
		_maximize_profile()
	else:
		_minimize_profile()
