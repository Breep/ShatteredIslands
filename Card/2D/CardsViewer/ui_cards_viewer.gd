class_name UICardsViewer
extends Control

enum SortMode {
	NONE,
	RARITY,
	LEVEL,
	UNLOCKED,
	NAME,
}

@onready var _grid_container: GridContainer = %GridContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer
@onready var _sort_rarity_button: Button = %SortRarityButton
@onready var _sort_level_button: Button = %SortLevelButton
@onready var _sort_unlocked_button: Button = %SortUnlockedButton
@onready var _sort_name_button: Button = %SortNameButton

const CARD_BUTTON_SCENE: PackedScene = preload("res://Card/2D/CardButton/card_button.tscn")

var _current_cards: Array[Card] = []
var _current_sort: SortMode = SortMode.NONE


func _ready() -> void:
	_sort_rarity_button.pressed.connect(_on_sort_pressed.bind(SortMode.RARITY))
	_sort_level_button.pressed.connect(_on_sort_pressed.bind(SortMode.LEVEL))
	_sort_unlocked_button.pressed.connect(_on_sort_pressed.bind(SortMode.UNLOCKED))
	_sort_name_button.pressed.connect(_on_sort_pressed.bind(SortMode.NAME))


func update_content(cards: Array[Card]) -> void:
	_current_cards = cards.duplicate()
	_current_sort = SortMode.NONE
	_rebuild_grid()


func reset_scroll() -> void:
	_scroll_container.scroll_vertical = 0


func _rebuild_grid() -> void:
	_clear_all()
	for card: Card in _current_cards:
		var card_button: CardButton = CARD_BUTTON_SCENE.instantiate()
		card_button.remove_shader()
		card_button.custom_minimum_size = Vector2(630, 880)
		card_button.update_visual(card)
		_grid_container.add_child(card_button)


func _sort_cards(sort_mode: SortMode) -> void:
	match sort_mode:
		SortMode.RARITY:
			_current_cards.sort_custom(func(a: Card, b: Card) -> bool:
				return a.rarity < b.rarity
			)
		SortMode.LEVEL:
			_current_cards.sort_custom(func(a: Card, b: Card) -> bool:
				return a.lvl > b.lvl
			)
		SortMode.UNLOCKED:
			pass
		SortMode.NAME:
			_current_cards.sort_custom(func(a: Card, b: Card) -> bool:
				return a.name.naturalnocasecmp_to(b.name) < 0
			)


func _clear_all() -> void:
	for child: CardButton in _grid_container.get_children():
		child.queue_free()


func _on_sort_pressed(sort_mode: SortMode) -> void:
	if _current_sort == sort_mode:
		_current_cards.reverse()
	else:
		_current_sort = sort_mode
		_sort_cards(sort_mode)
	_rebuild_grid()
	reset_scroll()
