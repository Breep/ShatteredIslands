class_name UICardsViewer
extends Control

enum SortMode {
	NONE,
	RARITY,
	LEVEL,
	NAME,
}

enum DisplayMode {
	DEFAULT,
	UNLOCKED_ONLY
}

const CARD_BUTTON_SCENE: PackedScene = preload("res://Card/2D/CardButton/card_button.tscn")

@onready var _grid_container: GridContainer = %GridContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer

var _default_cards: Array[Card] = []
var _unlocked_cards: Array[Card] = []
var _unlocked_names: Dictionary[String, bool] = {}
var _current_sort: SortMode = SortMode.NONE
var _current_display: DisplayMode = DisplayMode.DEFAULT

var _card_tile_template: Control


#region ============================== Node base functions ==============================
func _ready() -> void:
	_card_tile_template = _grid_container.get_children()[0].duplicate()
#endregion


#region ============================== Public API ==============================
func update_content(default_cards: Array[Card], unlocked_cards: Array[Card]) -> void:
	_default_cards = default_cards
	_unlocked_cards = unlocked_cards
	_unlocked_names.clear()
	for card: Card in unlocked_cards:
		_unlocked_names[card.name] = true
	_sort_cards(_default_cards, SortMode.RARITY)
	_sort_cards(_unlocked_cards, SortMode.RARITY)
	_current_sort = SortMode.RARITY
	_rebuild_grid()


func reset_scroll() -> void:
	_scroll_container.scroll_vertical = 0


func sort_cards(sort_mode: SortMode) -> void:
	if _current_sort == sort_mode:
		_default_cards.reverse()
		_unlocked_cards.reverse()
	else:
		_current_sort = sort_mode
		_sort_cards(_default_cards, sort_mode)
		_sort_cards(_unlocked_cards, sort_mode)
	_rebuild_grid()
	reset_scroll()


func set_display_mode(mode: DisplayMode) -> void:
	if _current_display == mode:
		return
	_current_display = mode
	_rebuild_grid()
	reset_scroll()
#endregion


#region ============================== Private functions ==============================
func _sort_cards(cards: Array[Card], sort_mode: SortMode) -> void:
	match sort_mode:
		SortMode.RARITY:
			cards.sort_custom(func(a: Card, b: Card) -> bool:
				return a.rarity > b.rarity
			)
		SortMode.LEVEL:
			cards.sort_custom(func(a: Card, b: Card) -> bool:
				return a.lvl > b.lvl
			)
		SortMode.NAME:
			cards.sort_custom(func(a: Card, b: Card) -> bool:
				return a.name.naturalnocasecmp_to(b.name) < 0
			)


func _rebuild_grid() -> void:
	_clear_all()
	var cards_to_show: Array[Card] = _unlocked_cards if _current_display == DisplayMode.UNLOCKED_ONLY else _default_cards
	for card: Card in cards_to_show:
		var tile: Control = _card_tile_template.duplicate()
		var card_button: CardButton = tile.get_node("CardButton")
		card_button.update_visual(card)
		var is_locked: bool = not _unlocked_names.has(card.name)
		if _current_display == DisplayMode.DEFAULT and is_locked:
			card_button.set_locked(true)
		_grid_container.add_child(tile)


func _clear_all() -> void:
	for child in _grid_container.get_children():
		child.queue_free()
#endregion
 
