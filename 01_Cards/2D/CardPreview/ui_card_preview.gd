class_name UICardPreview
extends Control

const ROT_SPEED: float = 4

@onready var _canvas_group: CanvasGroup = %CanvasGroup
@onready var _card_layout: CardLayout = %CardLayout

var _card: Card

# Une pression a été reçue sur le preview : on attend son relâchement pour fermer,
# afin d'absorber les deux events (cf. _input).
var _dismissing: bool = false

var _angle_x_max: float = 15.0
var _angle_y_max: float = 15.0
var _target_rot_x: float
var _target_rot_y: float
var _current_rot_x: float
var _current_rot_y: float


func update_visual(new_card: Card) -> void:
	_card = new_card
	if new_card == null:
		printerr("Can't update preview visual: card is null")
		return
	_card_layout.update_content(new_card)


func _ready() -> void:
	_canvas_group.material = _canvas_group.material.duplicate()
	var target_scale: Vector2 = _canvas_group.scale
	var tween: Tween = create_tween()
	tween.tween_property(_canvas_group, "scale", target_scale, 0.2) \
		.from(target_scale * 0.85) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	_animation_3d_rotate(delta)


# Le preview est modal : tout clic le ferme. On consomme la pression ET le
# relâchement (free déféré au release) pour que ce même clic n'atteigne pas le
# _unhandled_input derrière — sinon le panneau du card shop, qui se ferme sur le
# relâchement gauche, se fermerait en même temps que le preview.
# Le release qui ouvre le preview (clic droit) n'est jamais vu en pression ici :
# `_dismissing` reste faux, donc il ne déclenche pas une fermeture immédiate.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			_dismissing = true
			get_viewport().set_input_as_handled()
		elif _dismissing:
			get_viewport().set_input_as_handled()
			queue_free()
	elif event is InputEventMouseMotion:
		_update_rotation_target()


func _update_rotation_target() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	_target_rot_x = lerpf(-_angle_x_max, _angle_x_max, lerp_val_x)
	_target_rot_y = lerpf(_angle_y_max, -_angle_y_max, lerp_val_y)


func _animation_3d_rotate(delta: float) -> void:
	if _current_rot_x == _target_rot_x and _target_rot_y == _current_rot_y:
		return
	_current_rot_x = lerp(_current_rot_x, _target_rot_x, delta * ROT_SPEED)
	_current_rot_y = lerp(_current_rot_y, _target_rot_y, delta * ROT_SPEED)
	_canvas_group.material.set_shader_parameter("x_rot", _current_rot_y)
	_canvas_group.material.set_shader_parameter("y_rot", _current_rot_x)
