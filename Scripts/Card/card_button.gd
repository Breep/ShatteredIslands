class_name CardButton
extends Control

# ============================== Signals ==============================

signal leftClick(card)

# ============================== Constants ==============================

const LAYER_FRONT = 1
const LAYER_BACK = 0

# ============================== Public variables ==============================

var card: Card:
	get: return _card
	set(_value): pass

# ============================== Private variables ==============================

var _angle_x_max: float = 15.0
var _angle_y_max: float = 15.0
var _tween_rot: Tween
var _tween_hover: Tween
var _card: Card
var _middle_offset: Vector2 = Vector2(125,175)

# ============================== Local scene nodes ==============================

@onready var _card_layout : CardLayout = $SubViewportContainer/SubViewport/CardLayout
@onready var _card_texture: SubViewportContainer = $SubViewportContainer

# ============================== Public functions ==============================

func update_visual(new_card: Card) -> void:
	_card = new_card
	if new_card == null:
		printerr("Can't update button visual: card is null")
		return
	_card_layout.update_card_layout(new_card)


# ============================== Node base functions ==============================

func _ready() -> void:
	%"0".pivot_offset = _middle_offset
	%"1".pivot_offset = _middle_offset
	%"2".pivot_offset = _middle_offset
	_card_texture.material = _card_texture.material.duplicate() # Make the material unique

func _on_mouse_entered() -> void:
	_animation_pop_out()


func _on_mouse_exited() -> void:
	_animation_reset_3d_rotation()
	_animation_pop_in()


func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_animation_3d_rotate()

	if event is InputEventMouseButton and event.is_pressed():
		leftClick.emit(_card)
		var animation_player = $SubViewportContainer/SubViewport/CardLayout.get_node("AnimationPlayer")
		if animation_player:
			animation_player.play("flip_card")
 
# ============================== Private functions ==============================

func _animation_3d_rotate() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	var rot_x: float = lerpf(-_angle_x_max, _angle_x_max, lerp_val_x)
	var rot_y: float = lerpf(_angle_y_max, -_angle_y_max, lerp_val_y)
	_card_texture.material.set_shader_parameter("x_rot", rot_y)
	_card_texture.material.set_shader_parameter("y_rot", rot_x)


# TODO Make the popout move the card slightly to the left so the popout seems centered
func _animation_pop_out() -> void:
	if _tween_hover:
		_tween_hover.kill()
	_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	z_index = LAYER_FRONT


func _animation_pop_in() -> void:
	if _tween_hover:
		_tween_hover.kill()
	_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
	z_index = LAYER_BACK


func _animation_reset_3d_rotation() -> void:
	if _tween_rot:
		_tween_rot.kill()
	_tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	_tween_rot.tween_property(_card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	_tween_rot.tween_property(_card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
