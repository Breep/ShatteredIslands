class_name UIBuyingArea
extends Control

@export var _round_timer: Timer

# ============================== Local nodes ==============================

@onready var _continous_timer: UIContinousTimer = %ContinousTimer

# ============================== Private variables ==============================

func _ready() -> void:
	#if multiplayer.is_server() and _selected_player != null:
		#_self_character_stats.connect_character_stats(_selected_player.character_stats)
	#elif not multiplayer.is_server():
		#_self_character_stats.connect_character_stats(PlayerManager.get_local_player().character_stats)
	#
	Events.ui_buying_area_opened.connect(_on_events_ui_buying_area_opened)
	
	_continous_timer.connect_timer(_round_timer)

# ============================== Callbacks ==============================

func _on_events_ui_buying_area_opened(is_opened: bool) -> void:
	if is_opened:
		show()
	else:
		hide()


















 
