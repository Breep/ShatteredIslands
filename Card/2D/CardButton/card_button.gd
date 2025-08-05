class_name CardButton
extends Control

# ============================== Signals ==============================

signal card_selected(self_ref: CardButton, card: Card)

# ============================== Constants ==============================

const LAYER_FRONT = 1
const LAYER_BACK = 0
const ROT_SPEED: float = 4

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

# ============================== Public functions ==============================

func update_visual(new_card: Card) -> void:
	_card = new_card
	if new_card == null:
		printerr("Can't update button visual: card is null")
		return
	_card_layout.update_card_layout(new_card)


# ============================== Node base functions ==============================

func _ready() -> void:
	_texture_rect.material = _texture_rect.material.duplicate() # Make the material unique


func _process(delta: float) -> void:
	_animation_3d_rotate(delta)


func _on_mouse_entered() -> void:
	_is_focused = true


func _on_mouse_exited() -> void:
	_is_focused = false
	_animation_reset_3d_rotation()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _is_focused:
		_update_rotation_target()

# ============================== Private functions ==============================

func _update_rotation_target() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	_target_rot_x = lerpf(-_angle_x_max, _angle_x_max, lerp_val_x)
	_target_rot_y = lerpf(_angle_y_max, -_angle_y_max, lerp_val_y)


func _animation_3d_rotate(delta: float) -> void:
	if _current_rot_x == _target_rot_x and _target_rot_y == _current_rot_y: return
	_current_rot_x = lerp(_current_rot_x, _target_rot_x, delta * ROT_SPEED)
	_current_rot_y = lerp(_current_rot_y, _target_rot_y, delta * ROT_SPEED)
	_texture_rect.material.set_shader_parameter("x_rot", _current_rot_y)
	_texture_rect.material.set_shader_parameter("y_rot", _current_rot_x)


func _animation_reset_3d_rotation() -> void:
	_target_rot_x = 0.0
	_target_rot_y = 0.0


func _on_gui_input(event: InputEvent) -> void:
	card_selected.emit(self, card)
	print("CardButton gui input [", get_path(), "]")
