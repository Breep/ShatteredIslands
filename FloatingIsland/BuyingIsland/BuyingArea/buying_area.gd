class_name BuyingArea
extends Node3D

# ============================== Signals ==============================

signal buying_phase_finished()

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Local nodes ==============================

@onready var _tavern: Tavern = %Tavern_Animated
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


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_ui_buying_area.set_active()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_ui_buying_area.set_inactive()


@rpc("authority", "call_local")
func _end_buying_round() -> void:
	buying_phase_finished.emit()
 
# ============================== Callbacks ==============================

func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		_end_buying_round.rpc()





























 
