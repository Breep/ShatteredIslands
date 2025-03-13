class_name BuyingArea
extends Node3D

signal phase_ended()

var _current_round: int
var _battles: Array[Battle]

@onready var _tavern: Tavern = %Tavern

func _ready() -> void:
	_current_round = RoundManager.current_round
	#_battles = RoundManager.get_current_round_battles()


# Reload the tavern center
func start_round(battles: Array[Battle]) -> void:
	CameraManager.camera_changed.emit(CameraManager.CameraType.BUYING_AREA)
	_tavern.put_tables_according_to_battles(battles)


func start_hero_selection(heroes: Array[Hero]) -> void:
	_tavern.init_hero_selection(heroes)
