extends Node2D
class_name PlayerVisual

# ============================== Local scene nodes ==============================

@onready var healthBar: ProgressBar = $HealthBar

# ============================== Public ==============================

func updateHealthBar(health: int, healthMax: int) -> void:
	healthBar.max_value = healthMax
	healthBar.value = health
