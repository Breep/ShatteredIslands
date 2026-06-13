# Proto shop + main : exerce le drag-and-drop entre UICardShop (mode proto) et
# UIHand. Pas de gold, pas de PlayerCardShop, pas de serveur. Les cartes sont
# tirées d'un ShopDeck (Resource) directement vers UICardShop.display_cards().
# Drop dans la drop_zone de UIHand → tentative d'ajout local via Hand.add_card.
#
# Sert aussi à valider le tutoriel forcé : le bouton "force achat" présente une
# étape BLOCKING (hole-punch sur le slot 0) pour vérifier que le drag d'achat
# traverse bien le blocker. On simule le TutorialManager en validant l'étape sur
# Events.card_bought.
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
@onready var _overlay: TutorialOverlay = %TutorialOverlay

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
	Events.card_bought.connect(_on_card_bought)
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


func _on_force_buy_button_pressed() -> void:
	var step: TutorialStep = TutorialStep.new()
	step.id = &"proto_force_buy"
	step.text = "Achète cette carte (drag vers ta main). Le reste est bloqué."
	step.target_unique_name = &"CardContainer"
	step.target_sub_name = &"VBoxContainer"
	step.validation_event = TutorialStep.ValidationEvent.CARD_BOUGHT
	step.popup_mode = TutorialStep.PopupMode.BLOCKING
	step.hide_skip = true
	step.highlight_target = true
	step.highlight_padding = 8.0
	step.auto_advance_delay = 0.0
	_overlay.present_step(step, true)


func _on_tuto_clear_button_pressed() -> void:
	_overlay.clear()


# Simule le TutorialManager : valide l'étape en cours dès qu'une carte est achetée.
func _on_card_bought(_card: Card) -> void:
	if _overlay.has_active_step():
		_overlay.complete_current_step()
#endregion


#region ============================== Private functions ==============================
func _refresh_shop() -> void:
	var cards: Array[Card] = _shop_deck.draw(_shop_cards_count, _rarity_chances)
	_ui_card_shop.display_cards(cards)


func _refresh_label() -> void:
	_hand_count_label.text = "%d / %d" % [_hand.size(), _hand.max_slots]
#endregion
