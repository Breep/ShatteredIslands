@tool

class_name UIInGamePlayerViewer
extends Control

# ============================== Effects Configurations ==============================

var _mirrored: bool
@export var mirrored: bool:
	get: return _mirrored
	set(value):
		_mirrored = value
		_mirror_ui()

@export_group("Effects Configuration")
@export var _effect_duration: float = 0.1

# ============================== Local Nodes ==============================

@onready var _texture_rect: TextureRect = %MainTextureRect
@onready var _hero_viewer: UIInGameHeroViewer = %InGameHeroViewer
@onready var _family_viewer: UIInGameFamilyViewer = %InGameFamilyViewer

@onready var _hero_level_texture_rect: TextureRect = %HeroLevelTextureRect
@onready var _player_hero_texture_rect: TextureRect = %PlayerHeroTextureRect
@onready var _stats_texture_rect: TextureRect = %StatsTextureRect

@onready var _family_name_description_texture_rect: TextureRect = %FamilyNameDescriptionTextureRect
@onready var _cards_viewer: UICardsViewer = %CardsViewer

# ============================== Node base function ==============================

func _ready() -> void:
	_mirror_ui()
	if not Engine.is_editor_hint():
		hide()
		_texture_rect.modulate.a = 0.0
		_hero_viewer.show()
		_family_viewer.hide()

# ============================== Public function ==============================

func show_panel() -> void:
	show()
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_texture_rect, "modulate:a", 1.0, _effect_duration).from(0.0)


func hide_panel() -> void:
	_texture_rect.modulate.a = 0.0
	hide()


func update_content(player: Player, family_type: Family.FamilyType = Family.FamilyType.UNDEF) -> void:
	if player == null or player.character == null: return
	if family_type == Family.FamilyType.UNDEF:
		_hero_viewer.update_content(player, player.character.stats)
		_hero_viewer.show()
		_family_viewer.hide()
	else:
		_family_viewer.update_content(player, GameManager._FAMILIES_REF[family_type])
		_hero_viewer.hide()
		_family_viewer.show()


func set_highlight_skills_by_type(highlight_style: HexButton.HighlightType, skill_type: Skill.SkillType, is_activated: bool) ->void:
	_hero_viewer.set_highlight_skills_by_type(highlight_style, skill_type, is_activated)


func set_highlight_skill_by_id(highlight_style: HexButton.HighlightType, skill_id: Skill.SkillID, is_activated: bool) ->void:
	_hero_viewer.set_highlight_skill_by_id(highlight_style, skill_id, is_activated)


func set_hover_skill_by_id(skill_id: Skill.SkillID, is_activated: bool) -> void:
	_hero_viewer.set_hover_skill_by_id(skill_id, is_activated)

# ============================== Private function ==============================

func _mirror_ui() -> void:
	if not is_node_ready(): return
	if _mirrored:
		_hero_level_texture_rect.flip_h = true
		_player_hero_texture_rect.flip_h = true
		_stats_texture_rect.flip_h = true
		_family_name_description_texture_rect.flip_h = true
		_cards_viewer.mirrored = true
	else:
		_hero_level_texture_rect.flip_h = false
		_player_hero_texture_rect.flip_h = false
		_stats_texture_rect.flip_h = false
		_family_name_description_texture_rect.flip_h = false
		_cards_viewer.mirrored = false
