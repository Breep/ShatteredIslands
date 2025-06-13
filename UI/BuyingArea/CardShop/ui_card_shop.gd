class_name UICardShop
extends Control

# ============================== Private variables ==============================

var _card_displayed: Array[Card]
var _local_player: Player

signal card_bought

# ============================== Local scene nodes ==============================

@onready var _card_shop_visual: CardShopVisual = %SubCardShop
@onready var _card_container: HBoxContainer = %CardContainer

# ============================== Node base functions ==============================

func _ready() -> void:
	if multiplayer.is_server(): 
		queue_free()
		return
	
	_local_player = PlayerManager.get_local_player()
	_update_shop_cards_displayed()

	for i in 3:
		var card_button = _card_container.get_node(str(i)) as CardButton
		card_button.connect("card_selected", _on_card_shop_button_pressed, CONNECT_ONE_SHOT)
	
	Events.ui_card_shop_opened.connect(_on_events_ui_card_shop_opened)


func _on_back_pressed() -> void:
	hide()


func _on_card_shop_button_pressed(card_button_selected: CardButton, card: Card) -> void:
	await _try_buy_card(card_button_selected, card)
	card_bought.emit()

# ============================== Private functions ==============================

# Try to buy a card for the local player
# It will ask the server for permission, if granted, all other players will be notified
func _try_buy_card(card_button_selected: CardButton, card: Card) -> void:
	if _local_player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		_reconnect_to_card_signal(card_button_selected)
		return
	
	if _local_player.gold < 100:
		print("CardShop: Can't pay the card")
		_reconnect_to_card_signal(card_button_selected)
		return
	
	var buy_ok = await MultiplayerDeckManager.try_buy_card_for_player(_local_player, card)
	if buy_ok:
		await _update_shop_cards_displayed()
	
	_reconnect_to_card_signal(card_button_selected)


func _update_shop_cards_displayed() -> void:
	if _local_player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return
	
	var cardsNumber = 3 # TODO For the moment there is no way to get more cards each time you buy, maybe in the futur
	_card_displayed = await MultiplayerDeckManager.smart_draw_n_cards(_local_player, _local_player.deck.get_max_lvl_cards(), cardsNumber)
	
	_adapt_cards_lvl_to_player()
	_card_shop_visual.update_shop_cards_displayed_visual(_card_displayed)


func _adapt_cards_lvl_to_player() -> void:
	for card in _card_displayed:
		card.lvl = _local_player.deck.get_card_lvl(card) + 1


func _reconnect_to_card_signal(card_button: CardButton) -> void:
	card_button.card_selected.connect(_on_card_shop_button_pressed, CONNECT_ONE_SHOT)


func _on_events_ui_card_shop_opened(is_opened: bool) -> void:
	if is_opened: show()
	else: hide()
