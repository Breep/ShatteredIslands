class_name UIInGameHeroViewer
extends Control

# ============================== Local Nodes ==============================

@export_group("Local Nodes")
@export var _player_name_label: Label
@export var _hero_name_label: Label
@export var _player_level_label: Label
@export var _statistic_container: UIEntityStatsContainer
@export var _skills_container: UIHeroSkillsContainer

@export_group("Match History")
@export var _match_history_ticks: Array[TextureRect]
@export var _unknown_color: Color
@export var _loose_color: Color
@export var _win_color: Color

# ============================== Node base functions ==============================

func _ready() -> void:
	_init_match_history_ticks()

# ============================== Public functions ==============================

func update_content(player: Player, current_stats: EntityStats) -> void:
	var hero: Hero = player.hero
	_player_level_label.text = str(player.lvl)
	_player_name_label.text = str(player.name)
	_hero_name_label.text = str(hero.name)
	_statistic_container.update_stats(current_stats)
	_skills_container.update_content(hero.skills)
	_update_match_history(player.battle_history)

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
	
