extends Control
class_name CardButton

# ============================== Local scene nodes ==============================

@onready var _cardLayout : CardLayout = $SubViewportContainer/SubViewport/CardLayout
@onready var _cardTexture: SubViewportContainer = $SubViewportContainer
@onready var _canvasLayer: CanvasLayer = $CanvasLayer

# ============================== Public ==============================

signal leftClick(card)

var card: Card:
	get: return _card
	set(_value): pass

# ============================== Private ==============================

var _angle_x_max: float = 15.0
var _angle_y_max: float = 15.0
var _tween_rot: Tween
var _tween_hover: Tween
var _card: Card

const LAYER_FRONT = 1
const LAYER_BACK = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	_tween_hover = create_tween()
	_tween_rot = create_tween()
	_cardTexture.material = _cardTexture.material.duplicate() # Make the material unique

func _on_mouse_entered() -> void:
	_animation_popOut()

func _on_mouse_exited() -> void:
	_animation_reset3dRotation()
	_animation_popIn()

func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_animation_3dRotate()
	if event is InputEventMouseButton and event.is_pressed():
		leftClick.emit(_card)
 
# ============================== Public functions ==============================

func updateVisual(card: Card) -> void:
	_card = card
	print(card.lvl)
	if card == null:
		printerr("Can't update button visual: card is null")
		return
	_cardLayout.updateCardLayout(card)


# ============================== Private functions ==============================

func _animation_3dRotate() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	var rot_x: float = lerpf(-_angle_x_max, _angle_x_max, lerp_val_x)
	var rot_y: float = lerpf(_angle_y_max, -_angle_y_max, lerp_val_y)
	_cardTexture.material.set_shader_parameter("x_rot", rot_y)
	_cardTexture.material.set_shader_parameter("y_rot", rot_x)

# TODO Make the popout move the card slightly to the left so the popout seems centered
func _animation_popOut() -> void:
	if _tween_hover:
		_tween_hover.kill()
		_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		_tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
		z_index = LAYER_FRONT

func _animation_popIn() -> void:
	if _tween_hover:
		_tween_hover.kill()
		_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		_tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
		z_index = LAYER_BACK

func _animation_reset3dRotation() -> void:
	if _tween_rot:
		_tween_rot.kill()
		_tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
		_tween_rot.tween_property(_cardTexture.material, "shader_parameter/x_rot", 0.0, 0.5)
		_tween_rot.tween_property(_cardTexture.material, "shader_parameter/y_rot", 0.0, 0.5)
