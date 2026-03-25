class_name DamagePopup2
extends Control

@onready var _damage_label: RichTextLabel = %DamageLabel

var _spawn_position: Vector3
var _damage_value: float

@export_group("Animation")
@export var param_ratio_value_min: float = 1
@export var param_ratio_value_max: float = 5000

@export_range(0.1, 5.0, 0.05) var base_scale: float = 1.0
@export_range(0.0, 0.5, 0.001) var effective_scale_max: float = 3

@export_range(0.0, 2.0, 0.1) var display_duration: float = 0.5 
@export_range(0.0, 5.0, 0.05) var fade_out_duration: float = 0.3
@export_range(0.0, 0.05, 0.001) var effective_display_duration_max: float = 1.0

@export_range(0.0, 300.0, 1.0) var rise_height: float = 40.0
@export_range(0.0, 0.05, 0.001) var effective_rise_max: float = 100

@export_group("Appearance")
@export var text_color: Color = Color.WHITE


#region ============================== Node base functions ==============================
func _ready() -> void:
	_damage_label.text = str(_damage_value).pad_decimals(0)
	_damage_label.modulate = text_color
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
	_damage_value = value
#endregion


#region ============================== Private API ==============================
func _pop() -> void:
	var scale_bonus: float = remap(_damage_value, param_ratio_value_min, param_ratio_value_max, 0, effective_scale_max)
	var effective_scale: float = clampf(base_scale + scale_bonus, base_scale, effective_scale_max)
	
	var rise_bonus: float = remap(_damage_value, param_ratio_value_min, param_ratio_value_max, 0, effective_rise_max)
	var effective_rise: float = clampf(rise_height + rise_bonus, rise_height, effective_rise_max)
	
	var display_duration_bonus: float = remap(_damage_value, param_ratio_value_min, param_ratio_value_max, 0, effective_display_duration_max)
	var effective_display_duration: float = clampf(display_duration + display_duration_bonus, display_duration, effective_display_duration_max)

	var tween = create_tween().set_parallel(true)

	# Montée avec léger aléatoire horizontal
	var move_offset = Vector2(randf_range(-30, 30), -effective_rise)
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
