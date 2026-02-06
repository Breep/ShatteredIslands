class_name Snake
extends Entity

@onready var _snake_visual: Node3D = %SnakeVisual

func _ready() -> void:
	_snake_visual.scale = Vector3.ZERO
	stats.health = stats.health_max
	var pop := create_tween()
	pop.tween_property(_snake_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_visual, "scale", Vector3.ONE * 1, 0.08)


func _animate_death() -> void:
	var pop := create_tween()
	pop.tween_property(_snake_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_snake_visual, "scale", Vector3.ZERO, 0.08)
