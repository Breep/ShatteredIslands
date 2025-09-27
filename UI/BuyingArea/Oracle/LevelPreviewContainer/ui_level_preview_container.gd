class_name UILevelPreviewContainer
extends Control

@onready var _container_title_label: Label = %ContainerTitleLabel

@onready var _skillA_portrait: TextureRect = %SkillAPortrait
@onready var _skillA_button: TextureButton = %SkillAButton
@onready var _skillA_border: TextureRect = %SkillAHexBorder
@onready var _skillB_portrait: TextureRect = %SkillBPortrait
@onready var _skillB_button: TextureButton = %SkillBButton
@onready var _skillB_border: TextureRect = %SkillBHexBorder

@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _skill_desc_label: Label = %SkillDescriptionLabel
@onready var _lock_skill_icon: TextureRect = %LockSkillIcon

var _skillA: Skill
var _skillB: Skill

const SKILL_PORTRAIT_BLINK_FREQUENCY: float = 5.0

func _ready() -> void:
	_skillA_portrait.material.set_shader_parameter("shader_parameter/frequency", 0)
	_skillB_portrait.material.set_shader_parameter("shader_parameter/frequency", 0)


func set_title(title: String) -> void:
	_container_title_label.text = title


func set_skills_info(skillA: Skill, skillB: Skill) -> void:
	_skillA = skillA
	_skillB = skillB
	_skillA_portrait.texture = skillA.portrait
	_skillB_portrait.texture = skillB.portrait


func _update_skill_desc_panel(skill: Skill) -> void:
	_skill_name_label.text = skill.name
	_skill_desc_label.text = skill.description


func _activate_outline_highlight(skill_border: TextureRect) -> void:
	var now := float(Time.get_ticks_msec()) / 1000.0
	skill_border.material.set_shader_parameter("start_time", now-1.0)
	skill_border.material.set_shader_parameter("effect_enabled", true)


func _desactivate_outline_highlight(skill_border: TextureRect) -> void:
	skill_border.material.set_shader_parameter("effect_enabled", false)



func _on_skill_a_button_pressed() -> void:
	_desactivate_outline_highlight(_skillB_border)
	_activate_outline_highlight(_skillA_border)


func _on_skill_b_button_pressed() -> void:
	_desactivate_outline_highlight(_skillA_border)
	_activate_outline_highlight(_skillB_border)
