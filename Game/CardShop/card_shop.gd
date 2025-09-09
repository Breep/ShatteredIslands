class_name CardShop
extends Node

# ============================== Signals ==============================

signal card_bought(card: Card)
signal shop_refreshed(new_cards: Array[Card])
signal shop_tried_to_refresh() # Used to notice UICardShop that it can reactivate its refresh button

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
		await _refresh_shop_cards()
		card_bought.emit(card)
	
	return true

# === REFRESH CARD SHOP ===

signal _server_refresh_permission_answered
var _server_refresh_permission_is_known: bool = false
var _server_refresh_permission_said_can_refresh: bool = false
func try_refresh_shop_cards() -> void:
	if player.gold < 20: return
	_server_refresh_permission_is_known = false
	_server_refresh_permission_said_can_refresh = false
	_ask_for_refresh_permission.rpc_id(1)
	if not _server_refresh_permission_is_known:
		await _server_refresh_permission_answered
	if _server_refresh_permission_said_can_refresh == true:
		await _refresh_shop_cards()
	shop_tried_to_refresh.emit()


@rpc("any_peer", "call_local", "reliable")
func _ask_for_refresh_permission() -> void:
	if not multiplayer.is_server():
		printerr("CardShop: Only the server can decide if the player can refresh !")
		return
	
	var peer_id: int = multiplayer.get_remote_sender_id()
	var can_refresh: bool = false
	if PlayerManager.players[peer_id].gold >= 20:
		PlayerManager.players[peer_id].gold -= 20
		can_refresh = true
	
	_answer_refresh_permission.rpc_id(peer_id, can_refresh)


@rpc("authority", "call_local", "reliable")
func _answer_refresh_permission(can_refresh: bool) -> void:
	_server_refresh_permission_said_can_refresh = can_refresh
	_server_refresh_permission_is_known = true
	_server_refresh_permission_answered.emit()

# ============================== Private functions ==============================

func _adapt_cards_lvl_to_player() -> void:
	for card in cards_displayed:
		card.lvl = player.deck.get_card_lvl(card) + 1


func _refresh_shop_cards() -> void:
	if player.deck == null:
		printerr("CardShop: Can't update shop cards, there is no player_deck")
		return
	
	cards_displayed = await MultiplayerDeckManager.smart_draw_n_cards(player, player.deck.get_max_lvl_cards(), cards_number)
	_adapt_cards_lvl_to_player()
	shop_refreshed.emit(cards_displayed)

# ============================== Callbacks ==============================

func _on_events_game_state_changed(state: Game.GameState) -> void:
	if state == Game.GameState.BUYING:
		_is_enabled = true
		if RoundManager.current_round == 1:
			_refresh_shop_cards()
	else:
		_is_enabled = false















 
