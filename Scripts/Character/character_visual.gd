class_name CharacterVisual
extends Node2D

# ============================== Local scene nodes ==============================

@onready var _health_bar: ProgressBar = $HealthBar

# ============================== Public ==============================

func update_health_bar(health: int, health_max: int) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health
