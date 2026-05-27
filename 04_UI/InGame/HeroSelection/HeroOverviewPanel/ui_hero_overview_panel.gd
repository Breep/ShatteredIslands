class_name UIHeroOverviewPanel
extends Control

# ============================== Local nodes ==============================

@onready var _hero_name_label: Label = %HeroNameLabel
@onready var _hero_portrait: TextureRect = %HeroPortrait
@onready var _stats_container: UIEntityStatsContainer = %StatsContainer
@onready var _hero_skills_container: UIHeroSkillsContainer = %HeroSkillsContainer
@onready var _lore_label: Label = %LoreLabel

@onready var _content_container: MarginContainer = %MarginContainer

# ============================== Node base functions ==============================

func _ready() -> void:
	_content_container.hide()

# ============================== Public functions ==============================

func display_hero_information(hero: HeroDesc) -> void:
	_content_container.show()
	_update_content(hero)

# ============================== Private functions ==============================

func _update_content(hero: HeroDesc) -> void:
	_hero_name_label.text = hero.name
	_hero_portrait.texture = hero.portrait
	var stats := EntityStats.new()
	stats.reset_from_hero_desc(hero, 1)
	_stats_container.update_stats(stats)
	#_hero_skills_container.update_content(hero.skills)
	_lore_label.text = hero.description




























 
