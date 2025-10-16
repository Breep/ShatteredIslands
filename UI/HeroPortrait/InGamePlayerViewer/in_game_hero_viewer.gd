class_name UIInGameHeroViewer
extends Control

# ============================== Local Nodes ==============================

@export_group("Local Nodes")
@export var _player_name_label: Label
@export var _hero_name_label: Label
@export var _player_level_label: Label
@export var _statistic_container: UIEntityStatsContainer
@export var _skills_container: UIHeroSkillsContainer

@export var _player_xp_progress_bar: TextureProgressBar
@export var _player_xp_border: TextureRect

@export_subgroup("Match History")
@export var _match_history_ticks: Array[TextureRect]
@export var _unknown_color: Color
@export var _loose_color: Color
@export var _win_color: Color

# ============================== Private variables ==============================

var _player: Player

# ============================== Node base functions ==============================

func _ready() -> void:
	_init_match_history_ticks()

# ============================== Public functions ==============================

func update_content(player: Player, current_stats: EntityStats) -> void:
	var hero: Hero = player.hero
	_player_name_label.text = str(player.name)
	_hero_name_label.text = str(hero.name)
	_statistic_container.update_stats(current_stats)
	_skills_container.update_content(hero.skills)
	_update_match_history(player.battle_history)
	_player_level_label.text = str(player.lvl)
	_player_xp_progress_bar.value = player.xp
	_player_xp_progress_bar.max_value = GameManager.game_rules.xp_per_levels[player.lvl]
	if _player != null and _player.lvl_changed.is_connected(_on_player_lvl_changed):
		_player.lvl_changed.disconnect(_on_player_lvl_changed)
	if _player != null and _player.xp_changed.is_connected(_on_player_xp_changed):
		_player.xp_changed.disconnect(_on_player_xp_changed)
	_player = player
	_player.lvl_changed.connect(_on_player_lvl_changed)
	_player.xp_changed.connect(_on_player_xp_changed)


func set_highlight_skills(skill_type: Skill.SkillType, is_activated: bool) -> void:
	if skill_type == Skill.SkillType.BRONZE:
		_skills_container.highlight_skill(Skill.SkillID.BRONZE1, HexButton.HighlightType.PLAIN, is_activated)
		_skills_container.highlight_skill(Skill.SkillID.BRONZE2, HexButton.HighlightType.PLAIN, is_activated)
	elif skill_type == Skill.SkillType.SILVER:
		_skills_container.highlight_skill(Skill.SkillID.SILVER1, HexButton.HighlightType.PLAIN, is_activated)
		_skills_container.highlight_skill(Skill.SkillID.SILVER2, HexButton.HighlightType.PLAIN, is_activated)
	elif skill_type == Skill.SkillType.GOLD:
		_skills_container.highlight_skill(Skill.SkillID.GOLD1, HexButton.HighlightType.PLAIN, is_activated)
		_skills_container.highlight_skill(Skill.SkillID.GOLD2, HexButton.HighlightType.PLAIN, is_activated)

# ============================== Private functions ==============================

func _init_match_history_ticks() -> void:
	for match_history_tick: TextureRect in _match_history_ticks:
		match_history_tick.modulate = _unknown_color

func _update_match_history(win_loose_history: Array[Battle.BattleResolution]) -> void:
	for i in _match_history_ticks.size():
		if i >= win_loose_history.size():
			return
		match win_loose_history[win_loose_history.size() - 1 - i]:
			Battle.BattleResolution.WIN: _match_history_ticks[_match_history_ticks.size() - 1 - i].modulate = _win_color
			Battle.BattleResolution.LOOSE: _match_history_ticks[_match_history_ticks.size() - 1 - i].modulate = _loose_color

# ============================== Private functions ==============================

func _on_player_lvl_changed(_player_ref: Player, new_player_lvl: int) -> void:
	if new_player_lvl >= 10:
		_player_xp_border.hide()
		_player_xp_progress_bar.hide()
	_player_level_label.text = str(new_player_lvl)
	_player_xp_progress_bar.max_value = GameManager.game_rules.xp_per_levels[new_player_lvl]


func _on_player_xp_changed(_player_ref: Player, new_player_xp: int) -> void:
	_player_xp_progress_bar.value = new_player_xp
