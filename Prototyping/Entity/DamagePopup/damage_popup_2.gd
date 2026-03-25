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
		position = camera.unproject_position(_spawn_position)

#region ============================== Public API ==============================
func init(spawn_position: Vector3) -> void:
	_spawn_position = spawn_position


func set_value(value: float) -> void:
	_damage_value = value
	
#region ============================== Private API ==============================
func _pop() -> void:

	var tween = create_tween().set_parallel(true)
	
	# 1. Animation de montée (Move up) avec un peu d'aléatoire horizontal
	var final_pos = position + Vector2(randf_range(-30, 30), -80)
	tween.tween_property(_damage_label, "position", final_pos, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	# 2. Effet d'impact (Scale pop)
	# On agrandit puis on rétrécit légèrement
	var impact_tween = create_tween()
	impact_tween.tween_property(_damage_label, "scale", scale * 1.2, 0.1)
	impact_tween.tween_property(_damage_label, "scale", scale, 0.1)

	# 3. Disparition progressive (Fade out)
	# On attend 0.3s avant de commencer à disparaître
	tween.tween_property(_damage_label, "modulate:a", 0.0, 0.4).set_delay(0.3)
	
	# 4. Nettoyage automatique
	tween.finished.connect(queue_free)
#endregion
