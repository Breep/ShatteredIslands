class_name BuyingArea
extends Node3D

var _current_round: int
var _battles: Array[Battle]

@onready var _tavern: Tavern = %Tavern

func _ready() -> void:
	_current_round = RoundManager.current_round
	#_battles = RoundManager.get_current_round_battles()
	

# Reload the tavern center
func start_round(battles: Array[Battle]) -> void:
	_tavern.start_round(battles)
