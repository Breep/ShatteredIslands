extends Control

const RARITY_COLORS: Dictionary[Card.Rarity, Color] = {
	Card.Rarity.COMMON: Color.LIGHT_GRAY,
	Card.Rarity.RARE: Color.LIGHT_SKY_BLUE,
	Card.Rarity.EPIC: Color.MEDIUM_PURPLE,
	Card.Rarity.LEGENDARY: Color.ORANGE,
}

# ============================== Exports ==============================

@export var _families: Array[Family]
@export var _extra_cards: Array[Card]

# ============================== Local scene nodes ==============================

@onready var _card_button: CardButton = %CardButton
@onready var _family_list: ItemList = %FamilyList
@onready var _card_list: ItemList = %CardList
@onready var _level_spin_box: SpinBox = %LevelSpinBox
@onready var _level_label: Label = %LevelLabel
@onready var _scale_slider: HSlider = %ScaleSlider
@onready var _scale_value_label: Label = %ScaleValueLabel

# ============================== Private variables ==============================

var _current_cards: Array[Card] = []
var _selected_card: Card

# ============================== Node base functions ==============================

func _ready() -> void:
	_populate_family_list()
	_family_list.item_selected.connect(_on_family_selected)
	_card_list.item_selected.connect(_on_card_selected)
	_level_spin_box.value_changed.connect(_on_level_changed)
	_scale_slider.value_changed.connect(_on_scale_changed)

	# Select first family if available
	if _family_list.item_count > 0:
		_family_list.select(0)
		_on_family_selected(0)

# ============================== Private functions ==============================

func _populate_family_list() -> void:
	_family_list.clear()
	for family in _families:
		_family_list.add_item(family.family_name, family.icon)

	if not _extra_cards.is_empty():
		_family_list.add_item("Extra Cards")


func _on_family_selected(index: int) -> void:
	_card_list.clear()
	_current_cards.clear()

	# Extra cards (last entry if present)
	if not _extra_cards.is_empty() and index == _families.size():
		_current_cards.assign(_extra_cards)
	else:
		var family: Family = _families[index]
		_current_cards.assign(family.get_cards())

	for card in _current_cards:
		var item_index: int = _card_list.add_item(card.name)
		_card_list.set_item_custom_fg_color(item_index, RARITY_COLORS[card.rarity])

	if _card_list.item_count > 0:
		_card_list.select(0)
		_on_card_selected(0)


func _on_card_selected(index: int) -> void:
	_selected_card = _current_cards[index]
	_update_level_spin_box()
	_update_card_display()


func _update_level_spin_box() -> void:
	var max_lvl: int = Card.RARITY_MAX_LEVEL[_selected_card.rarity]
	_level_spin_box.min_value = 1
	_level_spin_box.max_value = max_lvl
	_level_spin_box.value = clampi(_selected_card.lvl, 1, max_lvl)
	_level_label.text = "Level (1-%d)" % max_lvl


func _on_level_changed(value: float) -> void:
	if _selected_card == null:
		return
	_selected_card.lvl = int(value)
	_update_card_display()


func _on_scale_changed(value: float) -> void:
	_scale_value_label.text = "%.2f" % value
	_card_button.scale = Vector2(value, value)


func _update_card_display() -> void:
	_card_button.update_visual(_selected_card)
