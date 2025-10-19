class_name UIPersistant
extends Control

# ============================== Local nodes ==============================

@onready var _round_label: Label = %RoundLabel

# ============================== Node base functions ==============================

func _ready() -> void:
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)

# ============================== Public functions ==============================


# ============================== Callbacks ==============================

func _on_round_manager_current_round_changed(round_number: int) -> void:
	_round_label.text = str("ROUND ") + str(round_number)
