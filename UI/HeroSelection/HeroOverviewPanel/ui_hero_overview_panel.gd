class_name UIHeroOverviewPanel
extends Control

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

@onready var _lore_label: Label

@onready var _content_container: MarginContainer = %MarginContainer
