class_name UIHeroPortrait
extends Control

# ============================== Configuration ==============================

@export_group("Effects Configuration")
@export var _effect_duration: float = 0.4

# ============================== Local nodes ==============================

@onready var _ui_all_families_portrait: UIAllFamiliesPortrait = %UIAllFamiliesPortrait
@onready var _ui_in_game_player_viewer: UIInGamePlayerViewer = %InGamePlayerViewer
@onready var _minimize_button: TextureButton = %MinimizeButton
@onready var _hex_portrait_button: HexButton = %HexPortraitButton

# ============================== Private variables ==============================

var _is_active: bool = false
var _panel_minimized: bool = false
var _player: Player

# ============================== Node base functions ==============================

func _ready() -> void:
	_minimize_button.hide()
	_ui_all_families_portrait.init_portait_families(GameManager.active_families)
	_ui_all_families_portrait.family_selected.connect(_on_ui_all_families_portrait_family_selected)

# ============================== Public functions ==============================

func update_content(player: Player) -> void:
	var hero: Hero = player.hero
	_hex_portrait_button.set_texture(hero.portrait)
	_ui_in_game_player_viewer.update_content(player)
	_ui_all_families_portrait.update_content(player)
	_player = player
	_add_local_player_special_behaviour()

# ============================== Private functions ==============================

func _activate() -> void:
	_ui_all_families_portrait.show_families()
	_ui_in_game_player_viewer.show_panel()
	_ui_in_game_player_viewer.update_content(_player)
	_show_minimize_button()
	_is_active = true
	_panel_minimized = false


func _deactivate() -> void:
	_ui_all_families_portrait.hide_families()
	_ui_all_families_portrait.reset_buttons_state()
	_ui_in_game_player_viewer.hide_panel()
	_hide_minimize_button()
	_is_active = false
	_panel_minimized = true


func _minimize_profile() -> void:
	_ui_in_game_player_viewer.hide_panel()
	_ui_in_game_player_viewer.update_content(_player)
	_ui_all_families_portrait.reset_buttons_state()
	_panel_minimized = true


func _maximize_profile() -> void:
	_ui_in_game_player_viewer.show_panel()
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

func _add_local_player_special_behaviour() -> void:
	if not _player == PlayerManager.get_local_player():
		return
	_player.skill_manager.skill_unlocked.connect(_on_local_player_skill_manager_skill_unlocked)
	for skill_type: Skill.SkillType in _player.skill_manager.skills_pending.keys():
		if _player.skill_manager.skills_pending[skill_type] == true:
			_ui_in_game_player_viewer.set_highlight_skills(skill_type, true)

# ============================== Callbacks ==============================

func _on_hex_portrait_button_pressed() -> void:
	if _is_active:
		_deactivate()
	else:
		_activate()

func _on_minimize_button_pressed() -> void:
	if _panel_minimized:
		_maximize_profile()
	else:
		_minimize_profile()


func _on_ui_all_families_portrait_family_selected(family_type: Family.FamilyType) -> void:
	_ui_in_game_player_viewer.update_content(_player, family_type)
	if _panel_minimized:
		_maximize_profile()


func _on_local_player_skill_manager_skill_unlocked(skill_type: Skill.SkillType) -> void:
	_hex_portrait_button.set_highlight(HexButton.HighlightType.PLAIN, true)
	_ui_in_game_player_viewer.set_highlight_skills(skill_type, true)
