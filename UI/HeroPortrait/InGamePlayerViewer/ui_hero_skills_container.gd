class_name UIHeroSkillsContainer
extends Control

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _skill_buttons: Dictionary[Skill.SkillID, HexButton]

# ============================== Node base functions ==============================

func _ready() -> void:
	_colorize_buttons()

# ============================== Public functions ==============================

func update_content(skills: Dictionary[Skill.SkillID, Skill]) -> void:
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].set_texture(skills[skill_id].portrait)


func highlight_skill(skill_id: Skill.SkillID, highlight_type: HexButton.HighlightType, is_activated: bool) -> void:
	_skill_buttons[skill_id].set_highlight(highlight_type, is_activated)

# ============================== Private functions ==============================

func _colorize_buttons() -> void:
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].set_outline_color(Skill.COLORS[skill_id])
