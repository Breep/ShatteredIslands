# Carte du shop : Control avec tilt 3D shader (suit la souris) + lift/scale au
# survol + son hover/click. N'étend pas UIButton car ce n'est pas un Button —
# les sons sont déclenchés manuellement via AudioManager.play_ui().
class_name CardButton
extends Control

# ============================== Signals ==============================

signal card_selected(self_ref: CardButton, card: Card)
signal mouse_entered_card(card: Card)
signal mouse_exited_card(card: Card)

# ============================== Constants ==============================

const LAYER_FRONT = 1
const LAYER_BACK = 0
const ROT_SPEED: float = 4
const CARD_PREVIEW_SCENE: PackedScene = preload("res://01_Cards/2D/CardPreview/ui_card_preview.tscn")

const _HOVER_SCALE: float = 1.04
const _HOVER_LIFT_Y: float = -8.0
const _HOVER_TWEEN_IN: float = 0.15
const _HOVER_TWEEN_OUT: float = 0.20
const _APPEAR_START_SCALE: float = 0.7
const _APPEAR_DURATION: float = 0.25

# ============================== Public variables ==============================

var card: Card:
	get: return _card
	set(_value): pass

# ============================== Private variables ==============================

var _angle_x_max: float = 55.0
var _angle_y_max: float = 55.0
var _card: Card

var _target_rot_x: float
var _target_rot_y: float
var _current_rot_x: float
var _current_rot_y: float

var _is_focused: bool = false
var _hover_enabled: bool = true
var _hover_audio_enabled: bool = true
var _card_tween: Tween
var _canvas_base_position: Vector2
var _canvas_base_scale: Vector2

# ============================== Local scene nodes ==============================

@export var _card_layout : CardLayout
@export var _canvas_group: CanvasGroup

var _scroll_container: ScrollContainer

# ============================== Public functions ==============================

func update_visual(new_card: Card) -> void:
	_card = new_card
	if new_card == null:
		printerr("Can't update button visual: card is null")
		return
	_card_layout.update_content(new_card)


# Anime l'apparition : pop-in scale + fade-in alpha, après un délai optionnel.
# Appelé par UICardShop quand le shop refresh — délai stagger entre les cartes.
# Le son joue APRÈS le délai, en sync avec le début de l'animation visuelle.
func play_appear_animation(delay: float = 0.0) -> void:
	if _card_tween and _card_tween.is_running():
		_card_tween.kill()

	# État initial : invisible et rétréci, sans casser _canvas_base_*.
	modulate.a = 0.0
	_canvas_group.scale = _canvas_base_scale * _APPEAR_START_SCALE
	_canvas_group.position = _canvas_base_position

	_card_tween = create_tween().set_ease(Tween.EASE_OUT)
	if delay > 0.0:
		_card_tween.tween_interval(delay)
	_card_tween.tween_callback(func(): AudioManager.play_ui("card_drawn"))
	_card_tween.tween_property(self, "modulate:a", 1.0, _APPEAR_DURATION).set_trans(Tween.TRANS_SINE)
	_card_tween.parallel().tween_property(_canvas_group, "scale", _canvas_base_scale, _APPEAR_DURATION).set_trans(Tween.TRANS_BACK)

func remove_shader() -> void:
	_canvas_group.material = null


func set_locked(locked: bool) -> void:
	_canvas_group.self_modulate = Color(0.333, 0.333, 0.333, 1.0)
	#_card_layout.set_locked(locked)


# Désactive le survol (hover scale/lift + 3D shader tracking + son hover) et
# bloque les clics. Les signaux mouse_entered_card / mouse_exited_card restent
# émis pour que l'extérieur (UIHand) puisse piloter sa propre logique de hover.
func set_hover_enabled(enabled: bool) -> void:
	_hover_enabled = enabled
	if not enabled and _is_focused:
		_on_control_mouse_exited()


func set_hover_audio_enabled(enabled: bool) -> void:
	_hover_audio_enabled = enabled

# ============================== Node base functions ==============================

func _ready() -> void:
	if _canvas_group.material != null:
		_canvas_group.material = _canvas_group.material.duplicate()
	_canvas_base_position = _canvas_group.position
	_canvas_base_scale = _canvas_group.scale
	var parent := self as Node
	while parent:
		if parent is ScrollContainer:
			_scroll_container = parent
			break
		parent = parent.get_parent()


func _process(delta: float) -> void:
	_animation_3d_rotate(delta)

func _input(event: InputEvent) -> void:
	if not _hover_enabled: return
	if event is InputEventMouseMotion and _is_focused:
		_update_rotation_target()

# ============================== Private functions ==============================

func _update_rotation_target() -> void:
	if _canvas_group.material == null: return
	var mouse_pos: Vector2 = get_local_mouse_position()
	var size_x: float = _canvas_group.scale.x * _card_layout.size.x
	var size_y: float = _canvas_group.scale.y * _card_layout.size.y
	var lerp_val_x: float = remap(mouse_pos.x + size_x / 2, 0.0, size_x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y + size_y / 2, 0.0, size_y, 0, 1)
	_target_rot_x = lerpf(-_angle_x_max, _angle_x_max, lerp_val_x)
	_target_rot_y = lerpf(_angle_y_max, -_angle_y_max, lerp_val_y)


func _animation_3d_rotate(delta: float) -> void:
	if _canvas_group.material == null: return
	if _current_rot_x == _target_rot_x and _target_rot_y == _current_rot_y: return
	_current_rot_x = lerp(_current_rot_x, _target_rot_x, delta * ROT_SPEED)
	_current_rot_y = lerp(_current_rot_y, _target_rot_y, delta * ROT_SPEED)
	_canvas_group.material.set_shader_parameter("x_rot", _current_rot_y)
	_canvas_group.material.set_shader_parameter("y_rot", _current_rot_x)


func _animation_reset_3d_rotation() -> void:
	if _canvas_group.material == null: return
	_target_rot_x = 0.0
	_target_rot_y = 0.0


func _on_control_mouse_entered() -> void:
	mouse_entered_card.emit(_card)
	if not _hover_enabled: return
	_is_focused = true
	_card_layout.mouse_entered()
	_animate_hover(true)
	if _hover_audio_enabled:
		AudioManager.play_ui("card_drawn")


func _on_control_mouse_exited() -> void:
	mouse_exited_card.emit(_card)
	if not _is_focused: return
	_is_focused = false
	_animation_reset_3d_rotation()
	_card_layout.mouse_exited()
	_animate_hover(false)


func _on_control_gui_input(event: InputEvent) -> void:
	if not _hover_enabled: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			AudioManager.play_ui("button_click")
			card_selected.emit(self, card)
		elif event.button_index == MOUSE_BUTTON_RIGHT and _card != null:
			var preview: UICardPreview = CARD_PREVIEW_SCENE.instantiate()
			get_tree().root.add_child(preview)
			preview.update_visual(_card)


# Anime scale + lift + z-index pour faire ressortir la carte au survol.
# Important : on scale la CanvasGroup (pas le root Control), sinon le hit-test
# souris du Control change avec la scale et mouse_exited peut ne jamais firer.
# `entering = true` : pop-in avec léger overshoot. `false` : retour smooth.
func _animate_hover(entering: bool) -> void:
	if _card_tween and _card_tween.is_running():
		_card_tween.kill()

	# Si une appear-animation a été interrompue, on s'assure que l'alpha est OK.
	modulate.a = 1.0

	var scale_factor: float = _HOVER_SCALE if entering else 1.0
	var target_scale: Vector2 = _canvas_base_scale * scale_factor
	var target_pos: Vector2 = _canvas_base_position + Vector2(0, _HOVER_LIFT_Y) if entering else _canvas_base_position
	var duration: float = _HOVER_TWEEN_IN if entering else _HOVER_TWEEN_OUT

	# z_index instantané : on veut que la carte passe devant ses voisines dès l'entrée
	z_index = 1 if entering else 0

	_card_tween = create_tween().set_parallel(true)
	_card_tween.set_ease(Tween.EASE_OUT)
	_card_tween.set_trans(Tween.TRANS_BACK if entering else Tween.TRANS_SINE)
	_card_tween.tween_property(_canvas_group, "scale", target_scale, duration)
	_card_tween.tween_property(_canvas_group, "position", target_pos, duration)
