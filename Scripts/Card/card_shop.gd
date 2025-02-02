class_name CardShop
extends Control

# ============================== Private variables ==============================

var _card_displayed: Array[Card]
var _local_player: Player

signal card_bought

# ============================== Local scene nodes ==============================

@onready var _card_shop_visual: CardShopVisual = %CardShopVisual
@onready var _card_container: HBoxContainer = %CardContainer

# ============================== Node base functions ==============================

func _ready() -> void:
	_local_player = GameManager.get_local_player()

	_update_shop_cards_displayed()
	# tmp connect button signals
	# TODO make it in a separate function that can handle a custom number of button
	for i in 3:
		var cardButton = _card_container.get_node(str(i)) as CardButton
		cardButton.connect("leftClick", _on_card_shop_button_pressed, CONNECT_ONE_SHOT)


func _exit_tree() -> void:
	for card in _card_displayed:
		MultiplayerDeckManager.add_card(card)


func _on_back_pressed() -> void:
	print("Card shop closed")
	$".".hide()


func _on_card_shop_button_pressed(card: Card) -> void:
	_add_card_to_player_deck(card)
	card_bought.emit()

# ============================== Private functions ==============================

func _add_card_to_player_deck(card: Card) -> void:
	var cardButton_clicked: CardButton
	if _local_player.deck == null:
		printerr("Can't update shop cards, there is no player_deck")
		_reconnect_to_card_signal(cardButton_clicked)
		return
	
	if _local_player.gold < 1:
		print("Can't pay the card")
		_reconnect_to_card_signal(cardButton_clicked)
		return
	
	_local_player.gold -= 1
	_local_player.deck.add_card(card)
	var remaining_cards = []
	for i in 3:
		var cardButton = _card_container.get_node(str(i)) as CardButton
		if cardButton.visible:
			if cardButton.card.name != card.name:
				remaining_cards.append(cardButton.card)
			else:
				cardButton_clicked = cardButton
	
	for remaining_card in remaining_cards:
		MultiplayerDeckManager.add_card(remaining_card)
	
	await _update_shop_cards_displayed()
	_reconnect_to_card_signal(cardButton_clicked)


func _update_shop_cards_displayed() -> void:
	if _local_player.deck == null:
		printerr("Can't update shop cards, there is no player_deck")
		return
	
	var cardsNumber = 3 # TODO For the moment there is no way to get more cards each time you buy, maybe in the futur
	_card_displayed = await MultiplayerDeckManager.smart_draw_n_cards(_local_player.deck.get_max_lvl_cards(), cardsNumber)
	
	_adapt_cards_lvl_to_player()
	_card_shop_visual.update_shop_cards_displayed_visual(_card_displayed)


func _adapt_cards_lvl_to_player() -> void:
	for card in _card_displayed:
		card.lvl = _local_player.deck.get_card_lvl(card) + 1


func _reconnect_to_card_signal(cardButton: CardButton) -> void:
	cardButton.connect("leftClick", _on_card_shop_button_pressed, CONNECT_ONE_SHOT)
