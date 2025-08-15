class_name UIOracle
extends Control

@export_group("Skills")
@export var _skill1A: UISkillPanel
@export var _skill1B: UISkillPanel
@export var _skill2A: UISkillPanel
@export var _skill2B: UISkillPanel
@export var _skill3A: UISkillPanel
@export var _skill3B: UISkillPanel

@export_group("XP")
@export var _player_level_label: Label
@export var _xp_bar: ProgressBar
@export var _xp_label: Label

func _ready() -> void:
	pass


func _on_buy_xp_button_pressed() -> void:
	pass


func _on_close_button_pressed() -> void:
	hide()
