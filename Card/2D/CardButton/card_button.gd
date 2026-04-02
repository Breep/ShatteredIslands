class_name CardButton
extends Control

# ============================== Signals ==============================

signal card_selected(self_ref: CardButton, card: Card)

# ============================== Constants ==============================

const LAYER_FRONT = 1
const LAYER_BACK = 0
const ROT_SPEED: float = 4
const CARD_PREVIEW_SCENE: PackedScene = preload("res://Card/2D/CardPreview/ui_card_preview.tscn")

# ============================== Public variables ==============================

var card: Card:
	get: return _card
	set(_value): pass

# ============================== Private variables ==============================

var _angle_x_max: float = 15.0
var _angle_y_max: float = 15.0
var _card: Card

var _target_rot_x: float
var _target_rot_y: float
var _current_rot_x: float
var _current_rot_y: float

var _is_focused: bool = false

# ============================== Local scene nodes ==============================

@export var _card_layout : CardLayout
@export var _texture_rect: TextureRect

var _sub_viewport: SubViewport
var _scroll_container: ScrollContainer

# ============================== Public functions ==============================

func update_visual(new_card: Card) -> void:
	_card = new_card
	if new_card == null:
		printerr("Can't update button visual: card is null")
		return
	_card_layout.update_content(new_card)

func remove_shader() -> void:
	_texture_rect.material = null


func set_locked(locked: bool) -> void:
	_card_layout.set_locked(locked)

# ============================== Node base functions ==============================

func _ready() -> void:
	if _texture_rect.material != null:
		_texture_rect.material = _texture_rect.material.duplicate()
	_sub_viewport = _texture_rect.get_node("SubViewport") as SubViewport
	var parent := self as Node
	while parent:
		if parent is ScrollContainer:
			_scroll_container = parent
			break
		parent = parent.get_parent()


func _process(delta: float) -> void:
	_animation_3d_rotate(delta)
	_update_viewport_culling()


func _on_mouse_entered() -> void:
	_is_focused = true
	_card_layout.mouse_entered()


func _on_mouse_exited() -> void:
	_is_focused = false
	_animation_reset_3d_rotation()
	_card_layout.mouse_exited()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _is_focused:
		_update_rotation_target()

# ============================== Private functions ==============================

func _update_rotation_target() -> void:
	if _texture_rect.material == null: return
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	_target_rot_x = lerpf(-_angle_x_max, _angle_x_max, lerp_val_x)
	_target_rot_y = lerpf(_angle_y_max, -_angle_y_max, lerp_val_y)


func _animation_3d_rotate(delta: float) -> void:
	if _texture_rect.material == null: return
	if _current_rot_x == _target_rot_x and _target_rot_y == _current_rot_y: return
	_current_rot_x = lerp(_current_rot_x, _target_rot_x, delta * ROT_SPEED)
	_current_rot_y = lerp(_current_rot_y, _target_rot_y, delta * ROT_SPEED)
	_texture_rect.material.set_shader_parameter("x_rot", _current_rot_y)
	_texture_rect.material.set_shader_parameter("y_rot", _current_rot_x)


func _animation_reset_3d_rotation() -> void:
	if _texture_rect.material == null: return
	_target_rot_x = 0.0
	_target_rot_y = 0.0


func _update_viewport_culling() -> void:
	if _sub_viewport == null or _scroll_container == null:
		return
	var scroll_rect := _scroll_container.get_global_rect()
	var card_rect := get_global_rect()
	var is_visible_in_scroll := scroll_rect.intersects(card_rect)
	if is_visible_in_scroll and _sub_viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED:
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	elif not is_visible_in_scroll and _sub_viewport.render_target_update_mode != SubViewport.UPDATE_DISABLED:
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_selected.emit(self, card)
		elif event.button_index == MOUSE_BUTTON_RIGHT and _card != null:
			var preview: UICardPreview = CARD_PREVIEW_SCENE.instantiate()
			get_tree().root.add_child(preview)
			preview.update_visual(_card)
