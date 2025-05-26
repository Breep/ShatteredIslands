class_name BuyingArea
extends Node3D

# ============================== Signals ==============================

signal all_heroes_picked()
signal phase_ended()

signal _player_hero_picked()

# ============================== Private variables ==============================

var _battles: Array[Battle]

var _available_heroes: Array[Hero]

var _heroes_ready: int

# ============================== Local nodes ==============================

@onready var _tavern: Tavern = %Tavern

@onready var _ui_buying_area: UIBuyingArea = %UIBuyingArea

@onready var _timer: Timer = %BuyingAreaTimer

# ============================== Node base functions ==============================

func _ready() -> void:
	return

# ============================== Public functions ==============================

# Reload the tavern center
func start_round(battles: Array[Battle]) -> void:
	_timer.start()
	_tavern.put_tables_according_to_battles(battles)




@rpc("authority", "call_local")
func _end_buying_round() -> void:
	phase_ended.emit()
 
# ============================== Callbacks ==============================

func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		_end_buying_round.rpc()





























 
