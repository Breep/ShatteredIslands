class_name UIBraiseBubble
extends Control

# Tutorial speech bubble featuring Braise (the dragon mascot). Pop-in animation,
# typewriter text, optional arrow pointing at a UI target, and a Skip button.
# Self-positions next to its target, falls back to bottom-center if no target.

#region ============================== Signals ==============================
signal closed()
signal skipped()
#endregion


#region ============================== Constants ==============================
const POP_TIME: float = 0.2
const POP_SCALE := Vector2(0.85, 0.85)
const TYPEWRITER_CHARS_PER_SEC: float = 35.0
const TARGET_OFFSET: float = 24.0
const SCREEN_MARGIN: float = 16.0
#endregion


#region ============================== Enums ==============================
enum ArrowSide { NONE, LEFT, RIGHT, TOP, BOTTOM }
#endregion


#region ============================== Private variables ==============================
var _target: Control
var _pop_tween: Tween
var _typewriter_tween: Tween
var _breath_tween: Tween
var _closing: bool = false
#endregion


#region ============================== Local nodes ==============================
@onready var _panel: PanelContainer = %Panel
@onready var _portrait: TextureRect = %Portrait
@onready var _text_label: RichTextLabel = %TextLabel
@onready var _skip_button: Button = %SkipButton
@onready var _arrow_left: Label = %ArrowLeft
@onready var _arrow_right: Label = %ArrowRight
@onready var _arrow_top: Label = %ArrowTop
@onready var _arrow_bottom: Label = %ArrowBottom
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skip_button.pressed.connect(_on_skip_pressed)
	_hide_all_arrows()
	modulate.a = 0.0
	scale = POP_SCALE
#endregion


#region ============================== Public functions ==============================
func show_bubble(p_text: String, p_target: Control = null) -> void:
	_target = p_target
	_text_label.text = p_text
	_text_label.visible_ratio = 0.0

	await get_tree().process_frame
	_position_bubble()
	_pop_in()
	_start_typewriter(p_text.length())
	_start_breath()


func hide_bubble() -> void:
	if _closing: return
	_closing = true
	_kill_tween(_typewriter_tween)
	_kill_tween(_breath_tween)
	_kill_tween(_pop_tween)
	_pop_tween = create_tween()
	_pop_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_pop_tween.parallel().tween_property(self, "scale", POP_SCALE, POP_TIME)
	_pop_tween.parallel().tween_property(self, "modulate:a", 0.0, POP_TIME)
	_pop_tween.tween_callback(_on_hidden)


func complete_typewriter() -> void:
	_kill_tween(_typewriter_tween)
	_text_label.visible_ratio = 1.0
#endregion


#region ============================== Private functions ==============================
func _pop_in() -> void:
	pivot_offset = size * 0.5
	_kill_tween(_pop_tween)
	_pop_tween = create_tween()
	_pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pop_tween.parallel().tween_property(self, "scale", Vector2.ONE, POP_TIME)
	_pop_tween.parallel().tween_property(self, "modulate:a", 1.0, POP_TIME)


func _start_typewriter(char_count: int) -> void:
	_kill_tween(_typewriter_tween)
	if char_count <= 0: return
	var duration: float = max(0.05, char_count / TYPEWRITER_CHARS_PER_SEC)
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)


func _start_breath() -> void:
	_kill_tween(_breath_tween)
	_portrait.pivot_offset = _portrait.size * 0.5
	_breath_tween = create_tween().set_loops()
	_breath_tween.tween_property(_portrait, "scale", Vector2(1.05, 1.05), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_breath_tween.tween_property(_portrait, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _kill_tween(t: Tween) -> void:
	if t and t.is_valid():
		t.kill()


func _hide_all_arrows() -> void:
	_arrow_left.hide()
	_arrow_right.hide()
	_arrow_top.hide()
	_arrow_bottom.hide()


func _position_bubble() -> void:
	_hide_all_arrows()
	var viewport_size: Vector2 = get_viewport_rect().size
	var bubble_size: Vector2 = size
	if _target == null or not is_instance_valid(_target):
		var pos := Vector2(
			(viewport_size.x - bubble_size.x) * 0.5,
			viewport_size.y - bubble_size.y - SCREEN_MARGIN * 4.0
		)
		global_position = pos
		return

	var target_rect: Rect2 = _target.get_global_rect()
	var side: ArrowSide = _pick_side(target_rect, bubble_size, viewport_size)
	var pos: Vector2 = _compute_position(side, target_rect, bubble_size, viewport_size)
	global_position = pos
	_show_arrow(side)


func _pick_side(target_rect: Rect2, bubble_size: Vector2, viewport_size: Vector2) -> ArrowSide:
	var space_right: float = viewport_size.x - target_rect.end.x
	var space_left: float = target_rect.position.x
	var space_below: float = viewport_size.y - target_rect.end.y
	var space_above: float = target_rect.position.y

	if space_right >= bubble_size.x + TARGET_OFFSET + SCREEN_MARGIN:
		return ArrowSide.LEFT  # bubble is on the right of the target → arrow points left toward target
	if space_left >= bubble_size.x + TARGET_OFFSET + SCREEN_MARGIN:
		return ArrowSide.RIGHT
	if space_below >= bubble_size.y + TARGET_OFFSET + SCREEN_MARGIN:
		return ArrowSide.TOP
	if space_above >= bubble_size.y + TARGET_OFFSET + SCREEN_MARGIN:
		return ArrowSide.BOTTOM
	return ArrowSide.NONE


func _compute_position(side: ArrowSide, target_rect: Rect2, bubble_size: Vector2, viewport_size: Vector2) -> Vector2:
	var target_center: Vector2 = target_rect.get_center()
	var pos: Vector2
	match side:
		ArrowSide.LEFT:
			pos = Vector2(target_rect.end.x + TARGET_OFFSET, target_center.y - bubble_size.y * 0.5)
		ArrowSide.RIGHT:
			pos = Vector2(target_rect.position.x - bubble_size.x - TARGET_OFFSET, target_center.y - bubble_size.y * 0.5)
		ArrowSide.TOP:
			pos = Vector2(target_center.x - bubble_size.x * 0.5, target_rect.end.y + TARGET_OFFSET)
		ArrowSide.BOTTOM:
			pos = Vector2(target_center.x - bubble_size.x * 0.5, target_rect.position.y - bubble_size.y - TARGET_OFFSET)
		_:
			pos = Vector2((viewport_size.x - bubble_size.x) * 0.5, viewport_size.y - bubble_size.y - SCREEN_MARGIN * 4.0)

	pos.x = clamp(pos.x, SCREEN_MARGIN, viewport_size.x - bubble_size.x - SCREEN_MARGIN)
	pos.y = clamp(pos.y, SCREEN_MARGIN, viewport_size.y - bubble_size.y - SCREEN_MARGIN)
	return pos


func _show_arrow(side: ArrowSide) -> void:
	match side:
		ArrowSide.LEFT: _arrow_left.show()
		ArrowSide.RIGHT: _arrow_right.show()
		ArrowSide.TOP: _arrow_top.show()
		ArrowSide.BOTTOM: _arrow_bottom.show()
		_: pass
#endregion


#region ============================== Callbacks ==============================
func _on_skip_pressed() -> void:
	skipped.emit()
	hide_bubble()


func _on_hidden() -> void:
	closed.emit()
	queue_free()
#endregion
