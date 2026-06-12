class_name UIBraiseBubble
extends Control

# Tutorial speech bubble featuring Braise (the dragon mascot). Pop-in animation,
# typewriter text, optional arrow pointing at a UI target, and a Skip button.
# Self-positions next to its target, falls back to bottom-center if no target.

#region ============================== Signals ==============================
signal closed()
#endregion


#region ============================== Constants ==============================
const POP_TIME: float = 0.2
const POP_SCALE := Vector2(0.85, 0.85)
const TYPEWRITER_CHARS_PER_SEC: float = 35.0
## Distance (px) between the bubble's panel edge and the target's nearest edge.
## The arrow TextureRect extends 56px beyond the panel (offset_left = -56), and
## the actual arrow shape inside the texture might have a few px of padding,
## so we use a generous 80 to keep the visible tip clearly outside the target.
const TARGET_OFFSET: float = 80.0
const SCREEN_MARGIN: float = 16.0

## Bubble has a fixed width — text wraps inside that width and the bubble grows
## vertically (via NinePatchRect) to fit. Width and min height match the .tscn defaults.
const BUBBLE_WIDTH: float = 520.0
const BUBBLE_MIN_HEIGHT: float = 180.0
const BUBBLE_MAX_HEIGHT: float = 720.0
#endregion


#region ============================== Enums ==============================
enum ArrowSide { NONE, LEFT, RIGHT, TOP, BOTTOM }
#endregion


#region ============================== Private variables ==============================
var _target: Control
var _step: TutorialStep
var _pop_tween: Tween
var _typewriter_tween: Tween
var _breath_tween: Tween
var _closing: bool = false
#endregion


#region ============================== Local nodes ==============================
@onready var _panel: Panel = %Panel
@onready var _portrait: TextureRect = %Portrait
@onready var _name_label: Label = %NameLabel
@onready var _text_label: Label = %TextLabel
@onready var _skip_button: BaseButton = %SkipButton
@onready var _skip_label: Label = %SkipLabel
@onready var _arrow_left: TextureRect = %ArrowLeft
@onready var _arrow_right: TextureRect = %ArrowRight
@onready var _arrow_top: TextureRect = %ArrowTop
@onready var _arrow_bottom: TextureRect = %ArrowBottom

var _default_portrait: Texture2D
var _default_speaker_name: String
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skip_button.pressed.connect(_on_skip_pressed)
	_hide_all_arrows()
	modulate.a = 0.0
	scale = POP_SCALE
	_default_portrait = _portrait.texture
	_default_speaker_name = _name_label.text
#endregion


#region ============================== Public functions ==============================
func show_bubble(step: TutorialStep, p_target: Control = null, is_last: bool = false) -> void:
	_target = p_target
	_step = step

	_portrait.texture = step.portrait_texture if step.portrait_texture != null else _default_portrait
	_name_label.text = step.speaker_name if step.speaker_name != "" else _default_speaker_name
	_skip_label.text = "Fermer" if is_last else "Suivant"
	_skip_button.visible = not step.hide_skip

	_text_label.text = step.text
	_text_label.visible_ratio = 0.0

	# Lock the bubble's width first so the RichTextLabel can wrap to the right
	# size; THEN wait for two frames so the wrapped layout settles before we
	# read its minimum size. Without this, content_height returns the unwrapped
	# (huge) value and the bubble overflows the viewport, _pick_side returns
	# NONE, and the bubble falls back to bottom-center with no arrow.
	custom_minimum_size = Vector2(BUBBLE_WIDTH, BUBBLE_MIN_HEIGHT)
	size = Vector2(BUBBLE_WIDTH, BUBBLE_MIN_HEIGHT)
	await get_tree().process_frame
	await get_tree().process_frame

	_adapt_size_to_content()
	await get_tree().process_frame

	_position_bubble()
	_pop_in()
	_start_typewriter(step.text.length())


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
	_stop_breath()
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
	if char_count <= 0:
		_stop_breath()
		return
	var duration: float = max(0.05, char_count / TYPEWRITER_CHARS_PER_SEC)
	_start_breath()
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
	_typewriter_tween.tween_callback(_stop_breath)


func _start_breath() -> void:
	_kill_tween(_breath_tween)
	_portrait.pivot_offset = _portrait.size * 0.5
	_breath_tween = create_tween().set_loops()
	_breath_tween.tween_property(_portrait, "scale", Vector2(1.05, 1.05), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_breath_tween.tween_property(_portrait, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_breath() -> void:
	_kill_tween(_breath_tween)
	_portrait.scale = Vector2.ONE


func _kill_tween(t: Tween) -> void:
	if t and t.is_valid():
		t.kill()


func _hide_all_arrows() -> void:
	_arrow_left.hide()
	_arrow_right.hide()
	_arrow_top.hide()
	_arrow_bottom.hide()


## Width stays at BUBBLE_WIDTH (locked by show_bubble); this only adapts height
## to fit the wrapped content. The NinePatchRect panel and the MarginContainer
## follow via full-rect anchoring, so the visual frame stretches without
## breaking the gem corners. NameLabel stays anchored at the top of the VBox —
## only the bubble itself grows downward.
func _adapt_size_to_content() -> void:
	var margin_node: MarginContainer = _panel.get_node("Margin")
	var content_height: float = margin_node.get_combined_minimum_size().y
	var final_height: float = clamp(content_height, BUBBLE_MIN_HEIGHT, BUBBLE_MAX_HEIGHT)

	custom_minimum_size.y = final_height
	size.y = final_height


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
	var preferred: int = _step.preferred_arrow_side if _step != null else 0
	var side: ArrowSide = _pick_side(target_rect, bubble_size, viewport_size, preferred)
	var pos: Vector2 = _compute_position(side, target_rect, bubble_size, viewport_size)
	global_position = pos
	_show_arrow(side)


func _pick_side(target_rect: Rect2, bubble_size: Vector2, viewport_size: Vector2, preferred: int = 0) -> ArrowSide:
	# Honor a preferred side if the user set one and it has room.
	if preferred != 0:
		var preferred_side: ArrowSide = preferred as ArrowSide
		if _side_has_room(preferred_side, target_rect, bubble_size, viewport_size):
			return preferred_side

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


func _side_has_room(side: ArrowSide, target_rect: Rect2, bubble_size: Vector2, viewport_size: Vector2) -> bool:
	match side:
		ArrowSide.LEFT:
			return viewport_size.x - target_rect.end.x >= bubble_size.x + TARGET_OFFSET + SCREEN_MARGIN
		ArrowSide.RIGHT:
			return target_rect.position.x >= bubble_size.x + TARGET_OFFSET + SCREEN_MARGIN
		ArrowSide.TOP:
			return viewport_size.y - target_rect.end.y >= bubble_size.y + TARGET_OFFSET + SCREEN_MARGIN
		ArrowSide.BOTTOM:
			return target_rect.position.y >= bubble_size.y + TARGET_OFFSET + SCREEN_MARGIN
	return false


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
	hide_bubble()


func _on_hidden() -> void:
	closed.emit()
	queue_free()
#endregion
