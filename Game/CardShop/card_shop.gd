class_name CardShop
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

var _is_enabled: bool

# ============================== Node base functions ==============================

func _ready() -> void:
	Events.game_state_changed.connect(_on_events_game_state_changed)

# ============================== Public functions ==============================

# Try to buy a card for the player owner of this shop, It will ask the server for permission
func try_buy_card(card: Card) -> bool:
	if !_is_enabled or player.gold < 100: return false
	if not cards_displayed.has(card):
		printerr("CardShop: Can't buy this card [", card.name, "]: it's not in the cards displayed in the shop")
		shop_tried_to_buy_card.emit()
		return false
	
	var buy_ok = await ServerCardShop.try_buy_card_from_player_shop(player, card)
	if buy_ok:
		await _refresh_shop_cards(true)
		card_bought.emit(card)
	
	shop_tried_to_buy_card.emit()
	return true

# ============================== REFRESH CARD SHOP ==============================

func try_refresh_shop_cards() -> void:
	if !_is_enabled or player.gold < 20:
		shop_tried_to_refresh.emit()
		return
	await _refresh_shop_cards(false)
	shop_tried_to_refresh.emit()


# Try to buy a random card for the player owner of this shop, It will ask the server for permission
func try_buy_random_card() -> bool:
	if !_is_enabled or player.gold < 90: 
		shop_tried_to_buy_random_card.emit()
		return false
	var card: Card = await ServerCardShop.try_buy_random_card_for_player(player)
	if card != null:
		await _refresh_shop_cards(true)
		card_bought.emit(card)
	shop_tried_to_buy_random_card.emit()
	return card != null

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	for card in cards_displayed:
		card.lvl = player.deck.get_card_lvl(card) + 1


func _refresh_shop_cards(is_free: bool) -> void:
	if player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return
	
	cards_displayed = await ServerCardShop.try_refresh_shop_for_player(player, is_free)
	_adapt_cards_lvl_to_player()
	shop_refreshed.emit(cards_displayed)

# ============================== Callbacks ==============================

func _on_events_game_state_changed(state: Game.GameState) -> void:
	if state == Game.GameState.BUYING:
		_is_enabled = true
		if RoundManager.current_round == 1:
			_refresh_shop_cards(true)
	else:
		_is_enabled = false















 
