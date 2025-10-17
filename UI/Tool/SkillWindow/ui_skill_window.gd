class_name UISkillWindow
extends Control

# ============================== Public Variables ==============================

var dead_time: float = 0.5
var alive_time: float = 2.0
var follow_mouse: bool = false

# ============================== CONSTANTS ==============================

const POP_TIME: float = 0.15
const POP_SCALE := Vector2(0.9, 0.9)

# ============================== Private Variables ==============================

var _skill: Skill
var _spawn_pos: Vector2
var _mouse_in_window: bool = false

var _tween: Tween
var _poping_out: bool = false

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


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _mouse_in_window:
			_pop_out()

# ============================== Public functions ==============================

func init(skill: Skill, spawn_pos: Vector2) -> void:
	_skill = skill
	_spawn_pos = spawn_pos


func close() -> void:
	_pop_out()

# ============================== Private functions ==============================

func _pop_in() -> void:
	pivot_offset = size * 0.5
	modulate.a = 0.0
	scale = POP_SCALE
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE, POP_TIME)
	_tween.parallel().tween_property(self, "modulate:a", 1.0, POP_TIME)


func _pop_out() -> void:
	if _poping_out: return
	_poping_out = true
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "scale", POP_SCALE, POP_TIME)
	_tween.parallel().tween_property(self, "modulate:a", 0.0, POP_TIME)
	_tween.tween_callback(Callable(self, "queue_free"))
 
# ============================== Callbacks ==============================

func _on_mouse_entered() -> void:
	_mouse_in_window = true


func _on_mouse_exited() -> void:
	_mouse_in_window = false
