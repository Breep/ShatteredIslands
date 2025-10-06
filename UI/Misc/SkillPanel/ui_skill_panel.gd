class_name UISkillPanel
extends Control

# ============================== Signals ==============================

signal clicked(self_ref: UISkillPanel)

# ============================== Export ==============================

@export var _skill_level: int

# ============================== Local Nodes ==============================

@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _skill_description_label: Label = %SkillDescriptionLabel
@onready var _lock_container: Control = %LockContainer

# ============================== Private variables ==============================

var _is_locked: bool
var _is_picked: bool

func init(skill_name: String, skill_description: String) -> void:
	_skill_name_label.text = skill_name
	_skill_description_label.text = skill_description
