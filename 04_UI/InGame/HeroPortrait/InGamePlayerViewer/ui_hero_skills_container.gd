class_name UIHeroSkillsContainer
extends Control

# ============================== CONSTANT ==============================

var WAIT_TIME_BEFORE_SKILL_WINDOW: float = 0.5
const SKILL_WINDOW_SCENE: PackedScene = preload("res://04_UI/Tool/SkillWindow/ui_skill_window.tscn")

# ============================== Private variables ==============================

var _skills: Dictionary[Skill.SkillID, Skill]
var _skill_window_opened: UISkillWindow
var _hover_timer: Timer         # <— we'll create this dynamically
var _hovered_skill_id: Skill.SkillID

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _skill_buttons: Dictionary[Skill.SkillID, HexButton]

# ============================== Node base functions ==============================

func _ready() -> void:
	_colorize_buttons()
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].deactivate()
		_skill_buttons[skill_id].pressed.connect(_on_hex_button_pressed)
		_skill_buttons[skill_id].button_mouse_entered.connect(_on_hex_button_mouse_entered)
		_skill_buttons[skill_id].button_mouse_exited.connect(_on_hex_button_mouse_exited)
	_hover_timer = Timer.new()
	_hover_timer.one_shot = true
	add_child(_hover_timer)
	_hover_timer.timeout.connect(_on_hover_timer_timeout)

# ============================== Public functions ==============================

func update_content(skills: Dictionary[Skill.SkillID, Skill]) -> void:
	_skills = skills
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].set_texture(skills[skill_id].portrait)


func highlight_skill(skill_id: Skill.SkillID, highlight_type: HexButton.HighlightType, is_activated: bool = true) -> void:
	_skill_buttons[skill_id].set_highlight(highlight_type, is_activated)
	if highlight_type == HexButton.HighlightType.PLAIN:
		if is_activated:
			_skill_buttons[skill_id].activate()
		else:
			_skill_buttons[skill_id].deactivate()


func hover_skill(skill_id: Skill.SkillID, is_activated: bool = true) -> void:
	_skill_buttons[skill_id].set_hover_mode(is_activated)

# ============================== Private functions ==============================

func _colorize_buttons() -> void:
	for skill_id: Skill.SkillID in _skill_buttons.keys():
		_skill_buttons[skill_id].set_outline_color(Skill.COLORS[skill_id])


func _get_skill_id_from_hex_button(hex_button: HexButton) -> Skill.SkillID:
	return _skill_buttons.find_key(hex_button)


func _create_skill_window(skill: Skill) -> void:
	if _skill_window_opened != null and not _skill_window_opened.is_queued_for_deletion():
		_skill_window_opened.close()
	_skill_window_opened = SKILL_WINDOW_SCENE.instantiate()
	_skill_window_opened.init(skill, get_global_mouse_position())
	get_tree().root.add_child(_skill_window_opened)

# ============================== Callbacks ==============================

func _on_hex_button_pressed(button_ref: HexButton) -> void:
	var skill_id: Skill.SkillID = _get_skill_id_from_hex_button(button_ref)
	Events.signal_ui_skill_picked(skill_id)


func _on_hex_button_mouse_entered(button_ref: HexButton) -> void:
	_hovered_skill_id = _get_skill_id_from_hex_button(button_ref)
	_hover_timer.start(WAIT_TIME_BEFORE_SKILL_WINDOW)


func _on_hex_button_mouse_exited(_button_ref: HexButton) -> void:
	_hover_timer.stop()


func _on_hover_timer_timeout() -> void:
	if _hovered_skill_id != null:
		_create_skill_window(_skills[_hovered_skill_id])
