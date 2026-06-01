class_name PlayerCardShop
extends Node

# ============================== Signals ==============================

signal card_bought(card: Card)
signal shop_refreshed(new_cards: Array[Card])

signal shop_tried_to_refresh() # Used to notice UICardShop that it can reactivate its refresh button
signal shop_tried_to_buy_random_card() # Used to notice UICardShop that it can reactivate its random button
signal shop_tried_to_buy_card() # Used to notice UICardShop that it can reactivate its cards buttons

# ============================== Public variables ==============================

var cards_number: int = 3
var cards_displayed: Array[Card] # Cards available to be bought on the shop

var _player: Player # Player client/owner of this shop (can be a bot)
var player: Player:
	get: return _player
	set(value):
		if value == _player: return
		_player = value

# ============================== private variables ==============================

var _is_enabled: bool = true

# ============================== Node base functions ==============================

func _ready() -> void:
	Verbose.trace("PlayerCardShop._ready() | player=" + (_player.player_name if _player != null else "<null>"), Verbose.Category.CARD_SHOP)

# ============================== Public functions ==============================

# Initial / free population of the shop. UI calls this once it has bound to the
# shop_refreshed signal, after CardShopManager has been initialized.
func refresh_for_free() -> void:
	await _refresh_shop_cards(true)


# Try to buy a card for the player owner of this shop, It will ask the server for permission
func try_buy_card(card: Card) -> bool:
	Verbose.trace("PlayerCardShop.try_buy_card() | card=" + (card.name if card != null else "<null>") + " is_enabled=" + str(_is_enabled), Verbose.Category.CARD_SHOP)
	if !_is_enabled:
		Verbose.warn("Card shop is disabled", Verbose.Category.CARD_SHOP)
		shop_tried_to_buy_card.emit()
		return false

	var card_price: int = 100
	if player.gold < card_price:
		Verbose.warn("Not enought gold to buy this card | " + card.name + "(" + str(player.gold) + "<" + str(card_price) + ")", Verbose.Category.CARD_SHOP)
		if player == PlayerManager.get_local_player():
			Events.insufficient_gold.emit()
		shop_tried_to_buy_card.emit()
		return false
	if not cards_displayed.has(card):
		Verbose.error("Can't buy this card [" + card.name + "]: it's not in the cards displayed in the shop", Verbose.Category.CARD_SHOP)
		shop_tried_to_buy_card.emit()
		return false

	var buy_ok = await CardShopManager.try_buy_card_from_player_shop(player, card)
	Verbose.trace("PlayerCardShop.try_buy_card() | CardShopManager.try_buy_card_from_player_shop -> " + str(buy_ok), Verbose.Category.CARD_SHOP)
	if buy_ok:
		await _refresh_shop_cards(true)
		card_bought.emit(card)

	shop_tried_to_buy_card.emit()
	return true

# ============================== REFRESH CARD SHOP ==============================

func try_refresh_shop_cards() -> void:
	Verbose.trace("PlayerCardShop.try_refresh_shop_cards() | is_enabled=" + str(_is_enabled), Verbose.Category.CARD_SHOP)
	if !_is_enabled:
		Verbose.warn("Card shop is disabled", Verbose.Category.CARD_SHOP)
		shop_tried_to_refresh.emit()
		return

	var refresh_price: int = 20
	if player.gold < refresh_price:
		Verbose.warn("Not enought gold to refesh the shop"+ "(" + str(player.gold) + "<" + str(refresh_price) + ")", Verbose.Category.CARD_SHOP)
		if player == PlayerManager.get_local_player():
			Events.insufficient_gold.emit()
		shop_tried_to_refresh.emit()
		return

	await _refresh_shop_cards(false)
	shop_tried_to_refresh.emit()


# Try to buy a random card for the player owner of this shop, It will ask the server for permission
func try_buy_random_card() -> bool:
	Verbose.trace("PlayerCardShop.try_buy_random_card() | is_enabled=" + str(_is_enabled), Verbose.Category.CARD_SHOP)
	if !_is_enabled:
		Verbose.warn("Card shop is disabled", Verbose.Category.CARD_SHOP)
		shop_tried_to_buy_random_card.emit()
		return false
	if player.gold < 90:
		Verbose.warn("Not enought gold to buy a random card", Verbose.Category.CARD_SHOP)
		if player == PlayerManager.get_local_player():
			Events.insufficient_gold.emit()
		shop_tried_to_buy_random_card.emit()
		return false
	var card: Card = await CardShopManager.try_buy_random_card_for_player(player)
	Verbose.trace("PlayerCardShop.try_buy_random_card() | CardShopManager.try_buy_random_card_for_player -> " + (card.name if card != null else "<null>"), Verbose.Category.CARD_SHOP)
	if card != null:
		await _refresh_shop_cards(true)
		card_bought.emit(card)
	shop_tried_to_buy_random_card.emit()
	return card != null

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	Verbose.trace("PlayerCardShop._adapt_cards_lvl_to_player() | " + str(cards_displayed.size()) + " cards", Verbose.Category.CARD_SHOP)
	for card in cards_displayed:
		card.lvl = player.deck.get_card_lvl(card) + 1


func _refresh_shop_cards(is_free: bool) -> void:
	Verbose.trace("PlayerCardShop._refresh_shop_cards() | is_free=" + str(is_free) + " player=" + (player.player_name if player != null else "<null>"), Verbose.Category.CARD_SHOP)
	if player.deck == null:
		Verbose.error("Can't update shop cards, there is no player_deck", Verbose.Category.CARD_SHOP)
		return

	cards_displayed = await CardShopManager.try_refresh_shop_for_player(player, is_free)
	Verbose.trace("PlayerCardShop._refresh_shop_cards() | CardShopManager returned " + str(cards_displayed.size()) + " cards", Verbose.Category.CARD_SHOP)
	if cards_displayed.is_empty():
		Verbose.warn("PlayerCardShop._refresh_shop_cards() | CardShopManager returned 0 cards", Verbose.Category.CARD_SHOP)
	_adapt_cards_lvl_to_player()
	shop_refreshed.emit(cards_displayed)
