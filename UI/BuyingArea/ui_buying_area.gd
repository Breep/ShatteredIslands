class_name UIBuyingArea
extends Control

@export_group("External nodes")
@export var _round_timer: Timer

@export_group("Buttons")
@export var _random_button: Button
@export var _refresh_button: Button
@export var _back_button: Button

# ============================== Local nodes ==============================

@onready var _continous_timer: UIContinousTimer = %ContinousTimer
@onready var _ui_selected_entity_stats: UICharacterStats = %SelectedCharacterStats

# ============================== Private variables ==============================

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	_continous_timer.connect_timer(_round_timer)


func _on_events_entity_clicked(entity: Entity) -> void:
	if entity is Character:
		var character: Character = entity
		_ui_selected_entity_stats.connect_entity_stats(entity.stats, character.player.name)
	else:
		_ui_selected_entity_stats.connect_entity_stats(entity.stats, entity.name)














 
