class_name CardShop
extends Node

# ============================== Signals ==============================

signal card_bought(card: Card)
signal card_shop_refreshed(new_cards: Array[Card])

# ============================== Public variables ==============================

var cards_number: int = 3
var cards_displayed: Array[Card] # Cards available to be bought on the shop
var player: Player # Player client/owner of this shop (can be a bot)

# ============================== Node base functions ==============================

func _ready() -> void:
	if player == null:
		printerr("CardShop: Need a player to be owner of the shop")
		return
	
	refresh_shop_cards()

# ============================== Public functions ==============================

# Try to buy a card for the player owner of this shop, It will ask the server for permission
func try_buy_card(card: Card) -> void:
	if player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return
	
	if player.gold < 100:
		print("CardShop: Can't pay the card")
		return
	
	if not cards_displayed.has(card):
		printerr("CardShop: Can't buy this card [", card.name, "]: it's not in the cards displayed in the shop")
		return
	
	var buy_ok = await MultiplayerDeckManager.try_buy_card_for_player(player, card)
	if buy_ok:
		await refresh_shop_cards()
		card_bought.emit(card)


func refresh_shop_cards() -> void:
	if player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return
	
	cards_displayed = await MultiplayerDeckManager.smart_draw_n_cards(player, player.deck.get_max_lvl_cards(), cards_number)
	_adapt_cards_lvl_to_player()
	card_shop_refreshed.emit(cards_displayed)

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	for card in cards_displayed:
		card.lvl = player.deck.get_card_lvl(card) + 1
