class_name UIHeroSkillsContainer
extends Control

@export_group("Local Nodes")
@export var _skill_buttons: Dictionary[Skill.SkillID, HexButton]

func _ready() -> void:
	_colorize_buttons()


func update_content(skills: Dictionary[Skill.SkillID, Skill]) -> void:
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].set_texture(skills[skill_id].portrait)


func _colorize_buttons() -> void:
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].set_outline_color(Skill.COLORS[skill_id])
