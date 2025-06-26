class_name UIBuyingArea
extends Control

@export var _round_timer: Timer

# ============================== Local nodes ==============================

@onready var _continous_timer: UIContinousTimer = %ContinousTimer
@onready var _ui_selected_entity_stats: UICharacterStats = %SelectedCharacterStats
# ============================== Private variables ==============================

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	
	_continous_timer.connect_timer(_round_timer)


func _on_events_entity_clicked(entity: Entity) -> void:
	_ui_selected_entity_stats.connect_entity_stats(entity.stats)














 
