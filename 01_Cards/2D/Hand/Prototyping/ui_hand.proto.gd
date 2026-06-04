# Proto de l'éventail de main : exerce l'API publique de UIHand (bind, ajout,
# retrait, montée de niveau) en piochant dans un ShopDeck. Sert à valider la
# disposition en éventail (positions, rotations, transitions) en isolation.
extends Node

#region ============================== Export ==============================
@export var _shop_deck: ShopDeck
@export var _max_slots: int = 15
#endregion


#region ============================== Private vars ==============================
@onready var _ui_hand: UIHand = %UIHand
@onready var _count_label: Label = %CountLabel

var _hand: Hand
var _rarity_chances: Dictionary[Card.Rarity, float] = {
	Card.Rarity.COMMON: 50.0,
	Card.Rarity.RARE: 30.0,
	Card.Rarity.EPIC: 15.0,
	Card.Rarity.LEGENDARY: 5.0,
}
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_hand = Hand.new().init("Proto")
	_hand.max_slots = _max_slots
	_shop_deck.generate()
	_ui_hand.bind(_hand)
	_hand.has_changed.connect(_refresh_label)
	_refresh_label()
#endregion


#region ============================== Callbacks ==============================
func _on_add_button_pressed() -> void:
	var drawn: Array[Card] = _shop_deck.draw(1, _rarity_chances)
	for card: Card in drawn:
		if _hand.can_add(card):
			_hand.add_card(card)
		else:
			_shop_deck.add_card(card)


func _on_remove_button_pressed() -> void:
	var cards: Array[Card] = _hand.get_cards_raw()
	if cards.is_empty():
		return
	var card: Card = cards.back()
	var removed: Array[Card] = _hand.remove_card(card)
	for r: Card in removed:
		_shop_deck.add_card(r)


func _on_clear_button_pressed() -> void:
	var cards: Array[Card] = _hand.get_cards_raw().duplicate()
	for card: Card in cards:
		var removed: Array[Card] = _hand.remove_card(card)
		for r: Card in removed:
			_shop_deck.add_card(r)


func _refresh_label() -> void:
	_count_label.text = "%d / %d" % [_hand.size(), _hand.max_slots]
#endregion
