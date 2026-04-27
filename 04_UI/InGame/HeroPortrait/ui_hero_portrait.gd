class_name UIHeroPortrait
extends Control

@onready var _player_name_label: RichTextLabel = %PlayerNameLabel

func _ready() -> void:
	Events.entity_clicked.connect(_on_events_entity_clicked)


func _on_events_entity_clicked(entity: Entity) -> void:
	if not entity is Hero: return
	var hero: Hero = entity
	if hero.player != null:
		_player_name_label.text = hero.player.player_name
	else:
		_player_name_label.text = hero.entity_name
