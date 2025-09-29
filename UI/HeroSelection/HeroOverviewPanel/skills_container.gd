class_name UISkillsContainer
extends Control

@export var _skills_buttons: Dictionary[Skill.SkillID, HexButton]
@export var _skill_name_label: Label
@export var _skill_desc_label: Label

var _hero: Hero

func _ready() -> void:
	for skill_button in _skills_buttons.values():
		skill_button.pressed.connect(_on_skill_button_pressed)


func update_content(hero: Hero) -> void:
	_hero = hero
	_skills_buttons[Skill.SkillID.BRONZE1].texture = _hero.skill1A.portrait
	_skills_buttons[Skill.SkillID.BRONZE2].texture = _hero.skill1B.portrait
	_skills_buttons[Skill.SkillID.SILVER1].texture = _hero.skill2A.portrait
	_skills_buttons[Skill.SkillID.SILVER2].texture = _hero.skill2B.portrait
	_skills_buttons[Skill.SkillID.GOLD1].texture = _hero.skill3A.portrait
	_skills_buttons[Skill.SkillID.GOLD2].texture = _hero.skill3B.portrait


func _on_skill_button_pressed(skill_button: HexButton) -> void:
	for sb in _skills_buttons.values():
		if sb != skill_button:
			sb.desactivate_outline_highlight()
	
	var skill_id: Skill.SkillID = _skills_buttons.find_key(skill_button)
	_update_skill_panel(skill_id)


func _update_skill_panel(skill_id: Skill.SkillID) -> void:
	match skill_id:
		Skill.SkillID.BRONZE1:
			_skill_name_label.text = _hero.skill1A.name
			_skill_desc_label.text = _hero.skill1A.description
		Skill.SkillID.BRONZE2:
			_skill_name_label.text = _hero.skill1B.name
			_skill_desc_label.text = _hero.skill1B.description
		Skill.SkillID.SILVER1:
			_skill_name_label.text = _hero.skill2A.name
			_skill_desc_label.text = _hero.skill2A.description
		Skill.SkillID.SILVER2:
			_skill_name_label.text = _hero.skill2B.name
			_skill_desc_label.text = _hero.skill2B.description
		Skill.SkillID.GOLD1:
			_skill_name_label.text = _hero.skill3A.name
			_skill_desc_label.text = _hero.skill3A.description
		Skill.SkillID.GOLD2:
			_skill_name_label.text = _hero.skill3B.name
			_skill_desc_label.text = _hero.skill3B.description
