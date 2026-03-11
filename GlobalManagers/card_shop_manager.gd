extends Node

# ============================== Signals ==============================

signal _shop_deck_shuffled() # Server only

# ============================== Constants ==============================

const SERVER_ID = 1

# ============================== Public ==============================

enum ServerResponse {
	OK, # No error
	NOT_ENOUGHT_MONEY, # Client doesn't have enought money to buy the requested card
	CARD_NOT_BUYABLE, # Client try to buy a card that the server didn't draw for him
}
var _server_response: ServerResponse

# ============================== Public ==============================

var shop_deck: ShopDeck

# ============================== Private ==============================

# [Server only] Used to know if the server can start to answer clients
var _is_ready: bool = false
var _game_rules: GameRules
var _families: Array[Family]

# [Server only] Dictionary of all cards distributed in all player shop
var _cards_in_player_shop: Dictionary[int, Array] # { player_id, Array[Card] }

# ============================== NOde base functions ==============================

func _init() -> void:
	Verbose.debug("CARD SHOP MANAGER INIT", Verbose.Category.DEFAULT)

# ============================== Public INIT/CLEAR function ==============================

func clear() -> void:
	_cards_in_player_shop.clear()
	_is_ready = false


func init(families: Array[Family], rules: GameRules) -> void:
	_game_rules = rules
	_families = families
	_construct_shop_deck(families, rules)
	_init_cards_in_player_shop()
	
# ============================== Public functions ==============================
# Calling CardShopManager is different from client and server as there are multiple players at the same time on the server (1 human + n bots)

func try_refresh_shop_for_player(player: Player, is_free: bool) -> Array[Card]:
	Verbose.trace("try_refresh_shop_for_player() | " + player.player_name + " | " + str(is_free), Verbose.Category.CARD_SHOP)
	if multiplayer.is_server():
		return await _server_try_refresh_shop_for_player(player, is_free)
	else:
		return await _client_try_refresh_shop_for_player(is_free)


func try_buy_card_from_player_shop(player: Player, card: Card) -> bool:
	Verbose.trace("try_buy_card_from_player_shop() | " + player.player_name + " | " + card.name, Verbose.Category.CARD_SHOP)
	if multiplayer.is_server():
		return _server_try_buy_card_from_player_shop(player, card)
	else:
		return await _client_try_buy_card_from_player_shop(card)


func try_buy_random_card_for_player(player: Player) -> Card:
	Verbose.trace("try_buy_random_card_for_player() | " + player.player_name, Verbose.Category.CARD_SHOP)
	if multiplayer.is_server():
		return _server_try_buy_random_card_for_player(player)
	else:
		return await _client_try_buy_random_card_for_player()

# ============================== Private function ==============================

func _init_cards_in_player_shop() -> void:
	Verbose.trace("INIT CARDS IN PLAYER SHOP -> " + str(PlayerManager.players.keys()), Verbose.Category.CARD_SHOP)
	for player_id in PlayerManager.players.keys():
		_cards_in_player_shop[player_id] = []

func _construct_shop_deck(families: Array[Family], rules: GameRules) -> void:
	Verbose.trace("_construct_shop_deck() | " + str(families.size()), Verbose.Category.CARD_SHOP)
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(families, rules)
	_is_ready = true
	_shop_deck_shuffled.emit()

# ========== DRAW
func _server_draw_n_cards(player: Player, number_of_cards_to_draw: int) -> Array[Card]:
	Verbose.trace("_server_draw_n_cards() | " + player.player_name + " | " + str(number_of_cards_to_draw), Verbose.Category.CARD_SHOP)
	if not _is_ready: await _shop_deck_shuffled
	var cards_drawn = shop_deck.draw_cards_for_player(player, number_of_cards_to_draw)
	
	return cards_drawn

# ========== BUY A CARD FROM PLAYER CARD SHOP

func _server_try_buy_card_from_player_shop(player: Player, card_to_buy: Card) -> bool:
	Verbose.trace("_server_try_buy_card_from_player_shop() | " + player.player_name + " | " + card_to_buy.name, Verbose.Category.CARD_SHOP)
	if not card_to_buy in _cards_in_player_shop[player.id]:
		Verbose.error("Peer." + str(player.id) + " tries to buy a card not displayed in his shop [" + card_to_buy.name + "]", Verbose.Category.CARD_SHOP)
		return false
	
	if player.gold < 100: # TODO check gamerules for card price
		Verbose.warn("Peer." + str(player.id) + " is not rich enough", Verbose.Category.CARD_SHOP)
		return false
	
	_cards_in_player_shop[player.id].erase(card_to_buy)
	player.deck.add_card(card_to_buy)
	player.gold -= 100
	return true


signal _answer_for_buying_request_received()
func _client_try_buy_card_from_player_shop(card: Card) -> bool:
	Verbose.trace("_client_try_buy_card_from_player_shop() | " + card.name, Verbose.Category.CARD_SHOP)
	_ask_buy_card_from_player_shop.rpc_id(SERVER_ID, card.uid)
	await _answer_for_buying_request_received
	
	match _server_response:
		ServerResponse.OK:
			PlayerManager.get_local_player().deck.add_card(card)
			return true
		ServerResponse.NOT_ENOUGHT_MONEY:
			Verbose.warn("CardShopManager: Not enought money", Verbose.Category.CARD_SHOP)
			return false
		ServerResponse.CARD_NOT_BUYABLE:
			Verbose.error("CardShopManager: I can't buy this card [" + card.name + "]", Verbose.Category.CARD_SHOP)
			return false
	
	# Unreachable
	return false


@rpc("any_peer", "call_remote", "reliable")
func _ask_buy_card_from_player_shop(card_uid: int) -> void:
	Verbose.trace("_ask_buy_card_from_player_shop() | " + str(card_uid), Verbose.Category.CARD_SHOP)
	if not multiplayer.is_server(): return
	if not _is_ready: await _shop_deck_shuffled
	var peer_id: int = multiplayer.get_remote_sender_id()
	var card_to_buy: Card = _get_card_in_array(card_uid, _cards_in_player_shop[peer_id])
	if card_to_buy == null:
		Verbose.error("Peer." + str(peer_id) + " tries to buy a card not displayed in his shop", Verbose.Category.CARD_SHOP)
		_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.CARD_NOT_BUYABLE)
		return
	
	if PlayerManager.players[peer_id].gold < 100: # TODO check gamerules for card price
		Verbose.error("Peer." + str(peer_id) + " is not rich enough", Verbose.Category.CARD_SHOP)
		_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.NOT_ENOUGHT_MONEY)
		return
	
	_cards_in_player_shop[peer_id].erase(card_to_buy)
	PlayerManager.players[peer_id].deck.add_card(card_to_buy)
	PlayerManager.players[peer_id].gold -= 100
	_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.OK)


@rpc("authority", "call_remote", "reliable")
func _answer_buy_card_from_player_shop(server_response: ServerResponse) -> void:
	Verbose.trace("_answer_buy_card_from_player_shop() | " + str(server_response), Verbose.Category.CARD_SHOP)
	_server_response = server_response
	_answer_for_buying_request_received.emit()

# ========== BUY RANDOM CARD

func _server_try_buy_random_card_for_player(player: Player) -> Card:
	Verbose.trace("_server_try_buy_random_card_for_player() | " + player.player_name)
	if player.gold < 90:
		Verbose.warn("CardShopManager: (" + player.player_name + ") Not enought money", Verbose.Category.CARD_SHOP)
		return null
	var cards: Array[Card] = shop_deck.draw_cards_for_player(player, 1)
	if cards.is_empty():
		Verbose.warn("CardShopManager: (" + player.player_name + ") No more random card from the server", Verbose.Category.CARD_SHOP)
		return null
	player.deck.add_card(cards[0])
	player.gold -= 90
	return cards[0]


signal _server_buy_random_card_answered
var _random_card_bought: Card
func _client_try_buy_random_card_for_player() -> Card:
	Verbose.trace("_client_try_buy_random_card_for_player()", Verbose.Category.CARD_SHOP)
	_ask_buy_random_card_from_all.rpc_id(SERVER_ID)
	await _server_buy_random_card_answered
	match _server_response:
		ServerResponse.OK:
			PlayerManager.get_local_player().deck.add_card(_random_card_bought)
		ServerResponse.NOT_ENOUGHT_MONEY:
			Verbose.warn("CardShopManager: Not enought money", Verbose.Category.CARD_SHOP)
	return _random_card_bought


@rpc("any_peer", "call_remote", "reliable")
func _ask_buy_random_card_from_all() -> void:
	Verbose.trace("_ask_buy_random_card_from_all()", Verbose.Category.CARD_SHOP)
	if not multiplayer.is_server(): return
	if not _is_ready: await _shop_deck_shuffled
	var peer_id: int = multiplayer.get_remote_sender_id()
	var player: Player = PlayerManager.players[peer_id]
	if player.gold < 90:
		_answer_buy_random_card_from_all(-1, ServerResponse.NOT_ENOUGHT_MONEY)
		return
	var cards: Array[Card] = shop_deck.draw_cards_for_player(player, 1)
	player.deck.add_card(cards[0])
	player.gold -= 90
	_answer_buy_random_card_from_all.rpc_id(peer_id, cards[0].uid, ServerResponse.OK)


@rpc("authority", "call_remote", "reliable")
func _answer_buy_random_card_from_all(card_uid: int, server_response: ServerResponse) -> void:
	Verbose.trace("_answer_buy_random_card_from_all() | " + str(card_uid) + " | " + str(server_response), Verbose.Category.CARD_SHOP)
	_server_response = server_response
	_random_card_bought = shop_deck.get_card(card_uid)
	_server_buy_random_card_answered.emit()

# ========== REFRESH PLAYER CARD SHOP

func _server_try_refresh_shop_for_player(player: Player, is_free: bool) -> Array[Card]:
	Verbose.trace("_server_try_refresh_shop_for_player() | " + player.player_name + " | " + str(is_free), Verbose.Category.CARD_SHOP)
	var can_refresh: bool = false
	if is_free:
		can_refresh = true
	elif not is_free and player.gold >= 20:
		player.gold -= 20
		can_refresh = true
	
	if not can_refresh:
		return _cards_in_player_shop[player.id]
	
	for card_to_put_back in _cards_in_player_shop[player.id]:
		shop_deck.add_card(card_to_put_back)
	_cards_in_player_shop[player.id] = await _server_draw_n_cards(player, 3)
	
	return _cards_in_player_shop[player.id]


signal _server_refresh_shop_answered
var _server_refresh_shop_cards: Array[Card]
func _client_try_refresh_shop_for_player(is_free: bool) -> Array[Card]:
	Verbose.trace("_client_try_refresh_shop_for_player() | " + str(is_free), Verbose.Category.CARD_SHOP)
	if not is_free and PlayerManager.get_local_player().gold < 20: return []
	_server_refresh_shop_cards.clear()
	_ask_for_refresh_shop.rpc_id(SERVER_ID, is_free)
	await _server_refresh_shop_answered
	return _server_refresh_shop_cards


@rpc("any_peer", "call_local", "reliable")
func _ask_for_refresh_shop(is_free: bool) -> void:
	Verbose.trace("_ask_for_refresh_shop() | " + str(is_free), Verbose.Category.CARD_SHOP)
	if not multiplayer.is_server(): return
	var peer_id: int = multiplayer.get_remote_sender_id()
	var player: Player = PlayerManager.players[peer_id]
	var can_refresh: bool = false
	if is_free:
		can_refresh = true
	elif not is_free and PlayerManager.players[peer_id].gold >= 20:
		PlayerManager.players[peer_id].gold -= 20
		can_refresh = true
	
	if can_refresh:
		for card_to_put_back in _cards_in_player_shop[player.id]:
			shop_deck.add_card(card_to_put_back)
		_cards_in_player_shop[player.id] = await _server_draw_n_cards(player, 3)
	
	var cards_uids: Array[int]
	for card in _cards_in_player_shop[player.id]:
		cards_uids.append(card.uid)
	_answer_refresh_shop.rpc_id(peer_id, cards_uids)


@rpc("authority", "call_local", "reliable")
func _answer_refresh_shop(cards_uids: Array[int]) -> void:
	Verbose.trace("_answer_refresh_shop() " + str(cards_uids), Verbose.Category.CARD_SHOP)
	for uid in cards_uids:
		_server_refresh_shop_cards.append(shop_deck.get_card(uid))
	_server_refresh_shop_answered.emit()

# ========== Tools

func _get_card_in_array(uid: int, cards: Array[Card]) -> Card:
	for card in cards:
		if card.uid == uid:
			return card
	return null
