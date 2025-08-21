class_name CardShop
extends Node

# ============================== Signals ==============================

signal card_bought(card: Card)
signal shop_refreshed(new_cards: Array[Card])

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
	if !_is_enabled:
		printerr("CardShop: CardShop is disabled")
		return false
	
	if player == null:
		printerr("CardShop: Need to be linked to a player [", get_path(), "]")
		return false
	
	if player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return false
	
	if player.gold < 100:
		print("CardShop: Can't pay the card")
		return false
	
	if not cards_displayed.has(card):
		printerr("CardShop: Can't buy this card [", card.name, "]: it's not in the cards displayed in the shop")
		return false
	
	var buy_ok = await MultiplayerDeckManager.try_buy_card_for_player(player, card)
	if buy_ok:
		await refresh_shop_cards()
		card_bought.emit(card)
	
	return true


func refresh_shop_cards() -> void:
	if _player == PlayerManager.get_local_player():
		print("REFRESH SHOP CARD 1 - LOCAL PLAYER")
	if player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return
	
	cards_displayed = await MultiplayerDeckManager.smart_draw_n_cards(player, player.deck.get_max_lvl_cards(), cards_number)
	_adapt_cards_lvl_to_player()
	shop_refreshed.emit(cards_displayed)

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	for card in cards_displayed:
		card.lvl = player.deck.get_card_lvl(card) + 1

# ============================== Callbacks ==============================

func _on_events_game_state_changed(state: Game.GameState) -> void:
	if state == Game.GameState.BUYING:
		_is_enabled = true
		if RoundManager.current_round == 1:
			refresh_shop_cards()
	















 
