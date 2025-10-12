class_name UIInGameHeroViewer
extends Control

@export_group("Local Nodes")
@export var _player_name_label: Label
@export var _hero_name_label: Label
@export var _player_level_label: Label
@export var _statistic_container: UIEntityStatsContainer
@export var _skills_container: UIHeroSkillsContainer


func update_content(player: Player, current_stats: EntityStats) -> void:
	var hero: Hero = player.hero
	_player_level_label.text = str(player.lvl)
	_player_name_label.text = str(player.name)
	_hero_name_label.text = str(hero.name)
	_statistic_container.update_stats(current_stats)
	_skills_container.update_content(hero.skills)
