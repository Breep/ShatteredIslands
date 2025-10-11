class_name UIHeroSkillsContainer
extends Control

@export_group("Local Nodes")
@export var _passive_button: HexButton
@export var _ultimate_button: HexButton
@export var _skill_bronze1: HexButton
@export var _skill_bronze2: HexButton
@export var _skill_silver1: HexButton
@export var _skill_silver2: HexButton
@export var _skill_gold1: HexButton
@export var _skill_gold2: HexButton


func update_content(skills: Dictionary[Skill.SkillID, Skill]) -> void:
	pass
