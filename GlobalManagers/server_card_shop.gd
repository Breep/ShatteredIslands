extends Node

# ============================== Signals ==============================

# [Client only] Is emit when server has answered the local client request to draw 3 cards
signal _answer_for_draw_received()

signal _shop_deck_shuffled() # Server only

# [Client only] Is emit when server has answered the local client request to buy a card
signal _answer_for_buying_request_received()

# ============================== Signals ==============================

const SERVER_ID = 1

# ============================== Public ==============================

enum ServerResponse {
	OK,                # No error
	NOT_ENOUGHT_MONEY, # Client doesn't have enought money to buy the requested card
	CARD_NOT_BUYABLE,  # Client try to buy a card that the server didn't draw for him
}
var _server_response: ServerResponse

# ============================== Public ==============================

var shop_deck: ShopDeck

# ============================== Private ==============================

# [Client only]
# Array of cards drawn by the server when the client ask for cards
# Used to communicate between 2 async rpc
var _cards_drawn: Array[Card]

# [Client only]
# Used to store server response for buying request


# [Server only] Used to know if the server can start to answer clients
var _is_ready: bool = false

# [Server only] Dictionary of all cards distributed in all player shop
var _cards_in_player_shop: Dictionary[int, Array] # { player_id, Array[Card] }

# ============================== Public INIT/CLEAR function ==============================

func clear() -> void:
	_cards_drawn.clear()
	_cards_in_player_shop.clear()
	_is_ready = false


func init(families: Array[Family], rules: GameRules) -> void:
	_init_cards_in_player_shop()
	_construct_shop_deck(families, rules)

# ============================== Public functions ==============================
# Calling ServerCardShop is different from client and server as there are multiple players at the same time on the server (1 human + n bots)

func try_refresh_shop_for_player(player: Player, is_free: bool) -> Array[Card]:
	if multiplayer.is_server():
		return await _server_try_refresh_shop_for_player(player, is_free)
	else:
		return await _client_try_refresh_shop_for_player(is_free)


func try_buy_card_from_player_shop(player: Player, card: Card) -> bool:
	if multiplayer.is_server():
		return _server_try_buy_card_from_player_shop(player, card)
	else:
		return await _client_try_buy_card_from_player_shop(card)


func try_buy_random_card_for_player(player: Player) -> Card:
	if multiplayer.is_server():
		return _server_try_buy_random_card_for_player(player)
	else:
		return await _client_try_buy_random_card_for_player()

# ============================== Private function ==============================

# ========== INIT SERVER CARD SHOP

func _init_cards_in_player_shop() -> void:
	print("INIT CARDS IN PLAYER SHOP -> ", PlayerManager.players.keys())
	for player_id in PlayerManager.players.keys():
		_cards_in_player_shop[player_id] = []


func _construct_shop_deck(families: Array[Family], rules: GameRules) -> void:
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(families, rules)
	#if multiplayer.is_server(): shop_deck.shuffle()
	_is_ready = true
	_shop_deck_shuffled.emit()

# ========== DRAW

func _server_draw_n_cards(player: Player, number_of_cards_to_draw: int) -> Array[Card]:
	if not _is_ready: await _shop_deck_shuffled
	var cards_to_remove: Array[Card] = player.deck.get_max_lvl_cards()
	var cards_drawn = shop_deck.smart_draw_n_cards(cards_to_remove, number_of_cards_to_draw)
	return cards_drawn


#func _client_draw_n_cards(number_of_cards_to_draw: int) -> Array[Card]:
	#_cards_drawn.clear()
	#_ask_draw_n_random_card.rpc_id(SERVER_ID, number_of_cards_to_draw)
	#await _answer_for_draw_received
	#return _cards_drawn
 #
#
## Client call this server rpc  to request the server to draw <number_of_cards_to_draw> cards from its shopdeck
## If possible, the server will draw as many cards as it can and store information about the cards draw in
## _cards_refs_displayed_in_player_shop[peer_id]. Then it will anwser the peer_id client only with an array
## of cards_ref_ids
#@rpc("any_peer", "call_local", "reliable")
#func _ask_draw_n_random_card(number_of_cards_to_draw: int) -> void:
	#if not multiplayer.is_server(): return
	#if not _is_ready: await _shop_deck_shuffled
	#var peer_id: int = multiplayer.get_remote_sender_id()
	#var cards_to_remove: Array[Card] = PlayerManager.players[peer_id].deck.get_max_lvl_cards()
	#var cards_drawn: Array[Card] = shop_deck.smart_draw_n_cards(cards_to_remove, number_of_cards_to_draw)
	#var cards_drawn_uids: Array[int]
	#for card in cards_drawn:
		#cards_drawn_uids.append(card.uid)
	#
	#_cards_in_player_shop[peer_id] = cards_drawn
	#_answer_draw_cards.rpc_id(peer_id, cards_drawn_uids)
#
#
#@rpc("authority", "call_local", "reliable")
#func _answer_draw_cards(cards_drawn_uids: Array[int]) -> void:
	#for uid in cards_drawn_uids:
		#_cards_drawn.append(shop_deck.card_pile[uid]) # TODO ADD a find card with uid in shopdeck
	#_answer_for_draw_received.emit()

# ========== BUY A CARD FROM PLAYER CARD SHOP

func _server_try_buy_card_from_player_shop(player: Player, card_to_buy: Card) -> bool:
	if not card_to_buy in _cards_in_player_shop[player.id]:
		printerr("[", multiplayer.get_unique_id(),"] Peer.", player.id, " try to buy a card not displayed in his shop [", card_to_buy.name, "]")
		return false
	
	if player.gold < 100: # TODO check gamerules for card price
		printerr("[", multiplayer.get_unique_id(),"]  Peer.", player.id, " is not rich enough")
		return false
	
	_cards_in_player_shop[player.id].erase(card_to_buy)
	player.deck.add_card(card_to_buy)
	player.gold -= 100
	shop_deck.remove_from_available_cards(card_to_buy)
	return true


func _client_try_buy_card_from_player_shop(card: Card) -> bool:
	_ask_buy_card_from_player_shop.rpc_id(SERVER_ID, card.uid)
	await _answer_for_buying_request_received
	
	match _server_response:
		ServerResponse.OK: 
			PlayerManager.get_local_player().deck.add_card(card)
			PlayerManager.get_local_player().gold -= 100
			return true
		ServerResponse.NOT_ENOUGHT_MONEY:
			print("ServerCardShop: [id:", multiplayer.get_unique_id(),"] Not enought money")
			return false
		ServerResponse.CARD_NOT_BUYABLE:
			print("ServerCardShop: [id:", multiplayer.get_unique_id(),"] I can't buy this card")
			return false
	
	# Unreachable
	return false


@rpc("any_peer", "call_local", "reliable")
func _ask_buy_card_from_player_shop(card_uid: int) -> void:
	if not multiplayer.is_server(): return
	if not _is_ready: await _shop_deck_shuffled
	var peer_id: int = multiplayer.get_remote_sender_id()
	var card_to_buy: Card = shop_deck.card_pile[card_uid]
	if not card_to_buy in _cards_in_player_shop[peer_id]:
		printerr("[", multiplayer.get_unique_id(),"] Peer.", peer_id, " try to buy a card not displayed in his shop")
		_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.CARD_NOT_BUYABLE)
		return
	
	if PlayerManager.players[peer_id].gold < 100: # TODO check gamerules for card price
		printerr("[", multiplayer.get_unique_id(),"]  Peer.", peer_id, " is not rich enough")
		_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.NOT_ENOUGHT_MONEY)
		return
	
	_cards_in_player_shop[peer_id].erase(card_to_buy)
	PlayerManager.players[peer_id].deck.add_card(card_to_buy)
	PlayerManager.players[peer_id].gold -= 100
	shop_deck.remove_from_available_cards(card_to_buy)
	_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.OK)


@rpc("authority", "call_local", "reliable")
func _answer_buy_card_from_player_shop(server_response: ServerResponse) -> void:
	_server_response = server_response
	_answer_for_buying_request_received.emit()

# ========== BUY RANDOM CARD

func _server_try_buy_random_card_for_player(player: Player) -> Card:
	if player.gold < 90: # TODO check gamerules for card price
		printerr("[", multiplayer.get_unique_id(),"]  Peer.", player.id, " is not rich enough")
		return null
	var cards_to_remove: Array[Card] = player.deck.get_max_lvl_cards()
	var cards: Array[Card] = shop_deck.smart_draw_n_cards(cards_to_remove, 1)
	player.deck.add_card(cards[0])
	player.gold -= 90
	return cards[0]


func _client_try_buy_random_card_for_player() -> Card:
	return null


# ========== REFRESH PLAYER CARD SHOP

func _server_try_refresh_shop_for_player(player: Player, is_free: bool) -> Array[Card]:
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
	if not is_free and PlayerManager.get_local_player().gold < 20: return []
	_server_refresh_shop_cards.clear()
	_ask_for_refresh_shop.rpc_id(SERVER_ID, is_free)
	await _server_refresh_shop_answered
	return _server_refresh_shop_cards


@rpc("any_peer", "call_local", "reliable")
func _ask_for_refresh_shop(is_free: bool) -> void:
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
	for uid in cards_uids:
		_server_refresh_shop_cards.append(shop_deck.card_pile[uid])
	_server_refresh_shop_answered.emit()
