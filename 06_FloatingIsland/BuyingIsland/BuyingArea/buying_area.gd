class_name BuyingArea
extends Node3D

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Local nodes ==============================

@onready var _tavern: Tavern = %Tavern_Animated

# ============================== Node base functions ==============================

func _ready() -> void:
	return

# ============================== Public functions ==============================

# Reload the tavern center
func start_round(battles: Array[Battle]) -> void:
	_tavern.put_tables_according_to_battles(battles)


func cleanup() -> void:
	_tavern.cleanup()


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()
