class_name UICardsViewer
extends Control

@onready var _grid_container: GridContainer = %GridContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer

const CARD_BUTTON_SCENE: PackedScene = preload("res://Card/2D/CardButton/card_button.tscn")

func update_content(cards: Array[Card]) -> void:
	_clear_all()
	for card: Card in cards:
		var card_button: CardButton = CARD_BUTTON_SCENE.instantiate()
		card_button.custom_minimum_size = Vector2(630, 880)
		card_button.update_visual(card)
		_grid_container.add_child(card_button)

func reset_scroll() -> void:
	_scroll_container.scroll_vertical = 0

func _clear_all() -> void:
	for child: CardButton in _grid_container.get_children():
		child.queue_free()
