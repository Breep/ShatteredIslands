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

@onready var _passive_name_label: Label = %PassiveName
@onready var _passive_description_label: Label = %PassiveDescription

@onready var _ultimate_name_label: Label = %UltimateName
@onready var _ultimate_description_label: Label = %UltimateDescription

@onready var _skill1A_name_label: Label = %Skill1AName
@onready var _skill1A_description_label: Label = %Skill1ADescription
@onready var _skill1B_name_label: Label = %Skill1BName
@onready var _skill1B_description_label: Label = %Skill1BDescription
@onready var _skill2A_name_label: Label = %Skill2AName
@onready var _skill2A_description_label: Label = %Skill2ADescription
@onready var _skill2B_name_label: Label = %Skill2BName
@onready var _skill2B_description_label: Label = %Skill2BDescription
@onready var _skill3A_name_label: Label = %Skill3AName
@onready var _skill3A_description_label: Label = %Skill3ADescription
@onready var _skill3B_name_label: Label = %Skill3BName
@onready var _skill3B_description_label: Label = %Skill3BDescription

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
	
	_health_label.text = str(hero.stats.health_max)
	_mana_label.text = str(hero.stats.mana_regen).pad_decimals(1)
	_dodge_label.text = str(int(hero.stats.dodge))
	_attack_label.text = str(hero.stats.attack_damage)
	_attack_speed_label.text = str(hero.stats.attack_speed).pad_decimals(1)
	_critic_label.text = str(int(hero.stats.physical_critical_chance))
	
	_passive_name_label.text = hero.passive_name
	_passive_description_label.text = hero.passive_description
	
	_ultimate_name_label.text = hero.ultimate_name
	_ultimate_description_label.text = hero.ultimate_description
	
	_skill1A_name_label.text = hero.skill1A_name
	_skill1A_description_label.text = hero.skill1A_description
	_skill1B_name_label.text = hero.skill1B_name
	_skill1B_description_label.text = hero.skill1B_description
	_skill2A_name_label.text = hero.skill2A_name
	_skill2A_description_label.text = hero.skill2A_description
	_skill2B_name_label.text = hero.skill2B_name
	_skill2B_description_label.text = hero.skill2B_description
	_skill3A_name_label.text = hero.skill3A_name
	_skill3A_description_label.text = hero.skill3A_description
	_skill3B_name_label.text = hero.skill3B_name
	_skill3B_description_label.text = hero.skill3B_description
	
	_lore_label.text = hero.description




























 
