extends Node3D

@onready var spark = %Spark
@onready var hit_effect = %HitEffect
@onready var decal = %Decal

func _ready() -> void:
	spark.emitting = true
	hit_effect.emitting = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(decal, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
