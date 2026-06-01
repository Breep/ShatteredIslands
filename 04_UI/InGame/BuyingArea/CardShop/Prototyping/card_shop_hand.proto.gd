# Proto shop + main : exerce le drag-and-drop entre UICardShop (mode proto) et
# UIHand. Pas de gold, pas de PlayerCardShop, pas de serveur. Les cartes sont
# tirées d'un ShopDeck (Resource) directement vers UICardShop.display_cards().
# Drop dans la drop_zone de UIHand → tentative d'ajout local via Hand.add_card.
extends Node

#region ============================== Export ==============================
@export var _shop_deck: ShopDeck
@export var _hand_max_slots: int = 15
@export var _shop_cards_count: int = 6
#endregion


#region ============================== Private vars ==============================
@onready var _ui_hand: UIHand = %UIHand
@onready var _ui_card_shop: UICardShop = %UICardShop
@onready var _hand_count_label: Label = %HandCountLabel

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
	_hand.max_slots = _hand_max_slots
	_shop_deck.generate()
	_ui_hand.bind(_hand)
	_hand.has_changed.connect(_refresh_label)
	_refresh_label()
	_refresh_shop()
#endregion


#region ============================== Callbacks ==============================
func _on_refresh_shop_button_pressed() -> void:
	_refresh_shop()


func _on_clear_hand_button_pressed() -> void:
	var cards: Array[Card] = _hand.get_cards_raw().duplicate()
	for card: Card in cards:
		var removed: Array[Card] = _hand.remove_card(card)
		for r: Card in removed:
			_shop_deck.add_card(r)
#endregion


#region ============================== Private functions ==============================
func _refresh_shop() -> void:
	var cards: Array[Card] = _shop_deck.draw(_shop_cards_count, _rarity_chances)
	_ui_card_shop.display_cards(cards)


func _refresh_label() -> void:
	_hand_count_label.text = "%d / %d" % [_hand.size(), _hand.max_slots]
#endregion
