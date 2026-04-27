class_name LabelPopup
extends Control

const SCENE: PackedScene = preload("res://02_Entities/_Shared/EntityInfoPanel/LabelPopup/label_popup.tscn")

const COLOR_PHYSICAL: Color = Color(0.934, 0.934, 0.934, 1.0)
const COLOR_MAGICAL:  Color = Color(0.0, 0.455, 0.952, 1.0)
const COLOR_POISON:   Color = Color.WEB_GREEN
const COLOR_PURE:     Color = Color(0.815, 0.656, 0.0, 1.0)
const COLOR_HEAL:     Color = Color(0.3, 1.0, 0.4)
const COLOR_DODGE:    Color = Color(0.011, 0.0, 0.821, 1.0)
const COLOR_BLOCK:    Color = Color(0.353, 0.165, 0.0, 1.0)

const CRIT_SCALE_MULTIPLIER: float = 1.5
const CRIT_RISE_MULTIPLIER: float = 1.5
const CRIT_DURATION_MULTIPLIER: float = 1.5
const CRIT_OUTLINE_COLOR: Color = Color(0.652, 0.083, 0.134, 1.0)

@onready var _damage_label: RichTextLabel = %DamageLabel

var _spawn_position: Vector3
var popup_value: float
var label_text: String = ""
var _is_crit: bool = false

@export_group("Animation")
@export_subgroup("Value Spreading")
@export var param_ratio_value_min: float = 1
@export var param_ratio_value_max: float = 5000

@export_subgroup("Scale")
@export_range(0.1, 5.0, 0.05) var base_scale: float = 1.0
@export_range(0.0, 0.5, 0.001) var effective_scale_max: float = 3

@export_subgroup("Display duration")
@export_range(0.0, 2.0, 0.1) var display_duration: float = 0.5 
@export_range(0.0, 5.0, 0.05) var fade_out_duration: float = 0.3
@export_range(0.0, 0.05, 0.001) var effective_display_duration_max: float = 1.0

@export_subgroup("Y Spread (Rise)")
@export_range(0.0, 300.0, 1.0) var rise_height: float = 20
@export_range(0.0, 0.05, 0.001) var effective_rise_max: float = 50

@export_subgroup("X spread (Left|Right)")
@export_range(0.0, 300.0, 1.0) var x_left: float = -30
@export_range(0.0, 0.05, 0.001) var x_right: float = 30

@export_group("Color")
@export var text_color: Color = Color.WHITE


#region ============================== Node base functions ==============================
func _ready() -> void:
	_damage_label.text = label_text if not label_text.is_empty() else str(popup_value).pad_decimals(0)
	_damage_label.add_theme_color_override("default_color", text_color)
	if _is_crit:
		_damage_label.text = "[center][shake rate=10.0 level=3.0]%s[/shake][/center]" % _damage_label.text
		_damage_label.rotation = deg_to_rad(randf_range(-15, 15))
		_damage_label.add_theme_color_override("font_outline_color", CRIT_OUTLINE_COLOR)
	else:
		_damage_label.text = "[center]%s[/center]" % _damage_label.text
	_pop()


func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera != null and _spawn_position != null:
		global_position = camera.unproject_position(_spawn_position)
#endregion


#region ============================== Public API ==============================
func init(spawn_position: Vector3) -> void:
	_spawn_position = spawn_position


func set_value(value: float) -> void:
	popup_value = value


func set_crit() -> LabelPopup:
	_is_crit = true
	return self


# --- Damage ---
static func damage_physical(value: float) -> LabelPopup:
	return _create(value, COLOR_PHYSICAL)


static func damage_magical(value: float) -> LabelPopup:
	return _create(value, COLOR_MAGICAL)


static func damage_poison(value: float) -> LabelPopup:
	return _create(value, COLOR_POISON)


static func damage_pure(value: float) -> LabelPopup:
	return _create(value, COLOR_PURE)


# --- Heal ---
static func heal(value: float) -> LabelPopup:
	return _create(value, COLOR_HEAL)


# --- Stack ---
static func stack(value: float, stack_type: Alteration.Type) -> LabelPopup:
	return _create(value, Alteration.get_color(stack_type))


static func stack_poison(value: float) -> LabelPopup:
	return stack(value, Alteration.Type.POISON)


static func stack_ignite(value: float) -> LabelPopup:
	return stack(value, Alteration.Type.IGNITE)


static func stack_necrosis(value: float) -> LabelPopup:
	return stack(value, Alteration.Type.NECROSIS)


static func stack_regen(value: float) -> LabelPopup:
	return stack(value, Alteration.Type.REGEN)


static func stack_shield(value: float) -> LabelPopup:
	return stack(value, Alteration.Type.SHIELD)


# --- Combat events ---
static func dodge(value: float = 0.0, is_crit: bool = false) -> LabelPopup:
	var popup := _create_text_with_value("Dodge", value, COLOR_DODGE)
	if is_crit:
		popup._is_crit = true
	return popup


static func block(value: float = 0.0, is_crit: bool = false) -> LabelPopup:
	var popup := _create_text_with_value("Block", value, COLOR_BLOCK)
	if is_crit:
		popup._is_crit = true
	return popup
#endregion


#region ============================== Private API ==============================
static func _create(value: float, color: Color) -> LabelPopup:
	var popup := SCENE.instantiate() as LabelPopup
	popup.popup_value = value
	popup.text_color = color
	return popup


static func _create_text(text: String, color: Color) -> LabelPopup:
	var popup := SCENE.instantiate() as LabelPopup
	popup.label_text = text
	popup.text_color = color
	return popup


static func _create_text_with_value(text: String, value: float, color: Color) -> LabelPopup:
	var popup := SCENE.instantiate() as LabelPopup
	popup.label_text = text
	popup.popup_value = value
	popup.text_color = color
	return popup


func _pop() -> void:
	var scale_bonus: float = remap(abs(popup_value), param_ratio_value_min, param_ratio_value_max, 0, effective_scale_max)
	var effective_scale: float = clampf(base_scale + scale_bonus, base_scale, effective_scale_max)
	
	var rise_bonus: float = remap(abs(popup_value), param_ratio_value_min, param_ratio_value_max, 0, effective_rise_max)
	var effective_rise: float = clampf(rise_height + rise_bonus, rise_height, effective_rise_max)
	
	var display_duration_bonus: float = remap(abs(popup_value), param_ratio_value_min, param_ratio_value_max, 0, effective_display_duration_max)
	var effective_display_duration: float = clampf(display_duration + display_duration_bonus, display_duration, effective_display_duration_max)
	
	if _is_crit:
		effective_scale *= CRIT_SCALE_MULTIPLIER
		effective_rise *= CRIT_RISE_MULTIPLIER
		effective_display_duration *= CRIT_DURATION_MULTIPLIER

	var tween = create_tween().set_parallel(true)

	# Montée avec léger aléatoire horizontal
	var move_offset = Vector2(randf_range(x_left, x_right), -effective_rise)
	tween.tween_property(_damage_label, "position", _damage_label.position + move_offset, 0.6) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Impact scale pop
	_damage_label.scale = Vector2.ONE * effective_scale
	tween.tween_property(_damage_label, "scale", Vector2.ONE * effective_scale * 1.2, 0.1)
	tween.tween_property(_damage_label, "scale", Vector2.ONE * effective_scale, 0.1).set_delay(0.1)

	# Fade out
	tween.tween_property(_damage_label, "modulate:a", 0.0, fade_out_duration).set_delay(effective_display_duration)

	tween.finished.connect(queue_free)
#endregion
