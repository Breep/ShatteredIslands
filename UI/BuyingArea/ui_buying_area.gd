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
@onready var _round_label: Label = %RoundLabel

# ============================== Private variables ==============================

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	_continous_timer.connect_timer(_round_timer)


func _on_events_entity_clicked(entity: Entity) -> void:
	if entity is Character:
		var character: Character = entity
		_ui_selected_entity_stats.connect_entity_stats(entity.stats, character.player.name)
	else:
		_ui_selected_entity_stats.connect_entity_stats(entity.stats, entity.name)


func _on_round_manager_current_round_changed(round_number: int) -> void:
	_round_label.text = str("ROUND ") + str(round_number)











 
