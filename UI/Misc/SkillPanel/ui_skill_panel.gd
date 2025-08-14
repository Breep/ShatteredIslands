class_name UISkillPanel
extends Control

# ============================== Signals ==============================

signal clicked(self_ref: UISkillPanel)

# ============================== Export ==============================

@export_group("Local Nodes")
@export var _skill_name: Label
@export var _skill_description: Label
@export var _lock_container: Control

@export_group("Configuration")
@export var _skill_level: int

# ============================== Private variables ==============================

var _is_locked: bool
var _is_picked: bool
