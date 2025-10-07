class_name UIHeroPortrait
extends Control

@onready var _ui_all_families_portrait: UIAllFamiliesPortrait = %UIAllFamiliesPortrait
@onready var _ui_in_game_player_profile: UIInGamePlayerProfile = %InGamePlayerProfile

var _is_active: bool = false

func _on_hex_portrait_button_pressed(self_ref: HexButton) -> void:
	if _is_active:
		_ui_all_families_portrait.hide_families()
		_ui_in_game_player_profile.hide_panel()
		_is_active = false
	else:
		_ui_all_families_portrait.show_families()
		_ui_in_game_player_profile.show_panel()
		_is_active = true
