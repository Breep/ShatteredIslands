class_name UISkillWindow
extends Control

# ============================== Public Variables ==============================

var dead_time: float = 0.5
var alive_time: float = 2.0
var follow_mouse: bool = false

# ============================== Private Variables ==============================

var _skill: Skill
var _spawn_pos: Vector2
var _mouse_in_window: bool = false

# ============================== Local nodes ==============================

@onready var _skill_name_label: Label = %SkillNameLabel
@onready var _skill_tier_level_label: SmartTextLabel = %SkillTierLevelLabel
@onready var _skill_description_label: SmartTextLabel = %SkillDescriptionLabel

# ============================== Node base functions ==============================

func _ready() -> void:
	if _skill == null: return
	_skill_name_label.text =_skill.name
	_skill_tier_level_label.text_raw = Skill.TIER_NAMES[_skill.skill_id]
	_skill_description_label.text_raw = _skill.description
	global_position = _spawn_pos
	_pop_in()

# ============================== Public functions ==============================

func init(skill: Skill, spawn_pos: Vector2) -> void:
	_skill = skill
	_spawn_pos = spawn_pos

# ============================== Private functions ==============================

func _pop_in() -> void:
	# POP in the screen with a small and minimalist tween effect
	pass

func _pop_out() -> void:
	# POP out of the screen with a small and minimalist tween effect
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _mouse_in_window:
			queue_free()
 
# ============================== Callbacks ==============================

func _on_mouse_entered() -> void:
	_mouse_in_window = true


func _on_mouse_exited() -> void:
	_mouse_in_window = false
