# Proto de la main : pioche des cartes du ShopDeck vers la main (selon des % de
# rareté éditables) et rend des cartes au ShopDeck. Valide la limite de slots,
# le leveling au doublon et le va-et-vient main <-> shop.
extends Node

@export var shop_deck: ShopDeck

@onready var _ui_shop_deck_cards_viewer: UICardsViewer = %UIShopDeckCardsViewer
@onready var _ui_hand_cards_viewer: UICardsViewer = %UIHandCardsViewer

@onready var _common_percent_text_edit: TextEdit = %CommonPercentTextEdit
@onready var _rare_percent_text_edit: TextEdit = %RarePercentTextEdit
@onready var _epic_percent_text_edit: TextEdit = %EpicPercentTextEdit
@onready var _legendary_percent_text_edit: TextEdit = %LegendaryPercentTextEdit

var _hand: Hand
# % de chance de pioche par rareté, alimenté par les TextEdit.
var _rarity_chances: Dictionary[Card.Rarity, float] = {}


func _ready() -> void:
	_hand = Hand.new()
	shop_deck.generate()
	_connect_percent_text_edits()
	_refresh_rarity_chances()
	_refresh_viewers()


func _on_draw_button_pressed() -> void:
	var drawn: Array[Card] = shop_deck.draw(1, _rarity_chances)
	for card: Card in drawn:
		_hand.add_card(card)
	_refresh_viewers()


func _on_give_back_button_pressed() -> void:
	var hand_cards: Array[Card] = _hand.get_cards_raw()
	if hand_cards.is_empty():
		return
	var card: Card = hand_cards.back()
	_hand.remove_card(card)
	shop_deck.add_card(card)
	_refresh_viewers()


func _refresh_viewers() -> void:
	_ui_shop_deck_cards_viewer.update_content(shop_deck.get_cards(), shop_deck.get_cards())
	_ui_hand_cards_viewer.update_content(_hand.get_cards_raw(), _hand.get_cards_raw())


func _connect_percent_text_edits() -> void:
	_common_percent_text_edit.text_changed.connect(_refresh_rarity_chances)
	_rare_percent_text_edit.text_changed.connect(_refresh_rarity_chances)
	_epic_percent_text_edit.text_changed.connect(_refresh_rarity_chances)
	_legendary_percent_text_edit.text_changed.connect(_refresh_rarity_chances)


func _refresh_rarity_chances() -> void:
	_rarity_chances[Card.Rarity.COMMON] = _parse_percent(_common_percent_text_edit.text)
	_rarity_chances[Card.Rarity.RARE] = _parse_percent(_rare_percent_text_edit.text)
	_rarity_chances[Card.Rarity.EPIC] = _parse_percent(_epic_percent_text_edit.text)
	_rarity_chances[Card.Rarity.LEGENDARY] = _parse_percent(_legendary_percent_text_edit.text)


func _parse_percent(text: String) -> float:
	var trimmed: String = text.strip_edges()
	return float(trimmed) if trimmed.is_valid_float() else 0.0
