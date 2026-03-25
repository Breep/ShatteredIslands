class_name DamagePopup2
extends Control

@onready var _damage_label: RichTextLabel = %DamageLabel
var _spawn_position: Vector3
var _damage_value: float

#region ============================== Node base functions ==============================
func _ready() -> void:
	_damage_label.text = str(_damage_value).pad_decimals(0)
	_pop()

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera != null and _spawn_position != null:
		global_position = camera.unproject_position(_spawn_position)

#region ============================== Public API ==============================
func init(spawn_position: Vector3) -> void:
	_spawn_position = spawn_position


func set_value(value: float) -> void:
	_damage_value = value
	
#region ============================== Private API ==============================
func _pop() -> void:
	var tween = create_tween().set_parallel(true)
	
	var move_offset = Vector2(randf_range(-30, 30), -40)
	var final_local_pos = _damage_label.position + move_offset

	tween.tween_property(_damage_label, "position", final_local_pos, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	_damage_label.scale = Vector2.ONE # Reset scale au cas où
	tween.tween_property(_damage_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(_damage_label, "scale", Vector2.ONE, 0.1).set_delay(0.1)

	tween.tween_property(_damage_label, "modulate:a", 0.0, 0.3).set_delay(0.4)
	
	tween.finished.connect(queue_free)
#endregion
