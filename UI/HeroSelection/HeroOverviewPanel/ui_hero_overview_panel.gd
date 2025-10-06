class_name UIHeroOverviewPanel
extends Control

# ============================== Local nodes ==============================

@onready var _hero_name_label: Label = %HeroNameLabel

@onready var _hero_portrait: TextureRect = %HeroPortrait

@onready var _health_label: Label = %HealthLabel
@onready var _mana_label: Label = %ManaLabel
@onready var _dodge_label: Label = %DodgeLabel
@onready var _attack_label: Label = %AttackLabel
@onready var _attack_speed_label: Label = %AttackSpeedLabel
@onready var _critic_label: Label = %CriticLabel

@onready var _passive_name_label: Label = %PassiveNameLabel
@onready var _passive_description_label: Label = %PassiveDescriptionLabel
@onready var _passive_portrait: TextureRect = %PassivePortrait

@onready var _ultimate_name_label: Label = %UltimateNameLabel
@onready var _ultimate_description_label: Label = %UltimateDescriptionLabel
@onready var _ultimate_portrait: TextureRect = %UltimatePortrait

@onready var _skill_container: UISkillsContainer = %SkillsContainer

@onready var _lore_label: Label = %LoreLabel

@onready var _content_container: MarginContainer = %MarginContainer

# ============================== Node base functions ==============================

func _ready() -> void:
	_content_container.hide()

# ============================== Public functions ==============================

func display_hero_information(hero: Hero) -> void:
	_content_container.show()
	_update_content(hero)

# ============================== Private functions ==============================

func _update_content(hero: Hero) -> void:
	_hero_name_label.text = hero.name
	_hero_portrait.texture = hero.portrait
	
	_health_label.text = str(hero.stats[1].health_max)
	_mana_label.text = str(hero.stats[1].mana_regen).pad_decimals(1)
	_dodge_label.text = str(int(hero.stats[1].dodge))
	_attack_label.text = str(hero.stats[1].attack_damage)
	_attack_speed_label.text = str(hero.stats[1].attack_speed).pad_decimals(1)
	_critic_label.text = str(int(hero.stats[1].physical_critical_chance))
	
	_passive_name_label.text = hero.passive.name
	_passive_description_label.text = hero.passive.description
	_passive_portrait.texture = hero.passive.portrait
	
	_ultimate_name_label.text = hero.ultimate.name
	_ultimate_description_label.text = hero.ultimate.description
	_ultimate_portrait.texture = hero.ultimate.portrait
	
	_skill_container.update_content(hero)
	
	_lore_label.text = hero.description




























 
