extends Node2D
# Global Singleton

# ========================================================================
# ========================================================================
# ====================                                ====================
# ====================     MultiPlayerDeckManager     ====================
# ====================                                ====================
# ========================================================================
# ========================================================================

# ============================== Signals ==============================

# [Client only] Is emit when server has anwsered the local client request to draw 3 cards
signal answer_for_draw_received()

signal shop_deck_shuffled() # Server only

# [Client only] Is emit when server has answered the local client request to buy a card
signal answer_for_buying_request_received()

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

# [Server only] All the cards of the shop
# Only the server knows what is inside the shop deck, client can only ask to draw and/or put back cards in it
# TODO Make the shopdeck more clever so it doesnt add more than it has given to clients
var shop_deck: ShopDeck

# ============================== Private ==============================

# Array of ALL current game cards with no duplicate
var _cards_refs: Array[Card]

# [Client only]
# Array of cards drawn by the server when the client ask for cards
# Used to communicate between 2 async rpc
var _cards_drawn: Array[Card]

# [Client only]
# Used to store server response for buying request


# [Server only] Used to know if the server can start to answer clients
var _is_ready: bool = false

# [Server only] Dictionary of all cards distributed in all player shop
var _cards_refs_displayed_in_player_shop: Dictionary[int, Array] # { player_id, Array[int] }

# ============================== Public function ==============================

# TODO Rework those 2 function to be private and and a MultiplayerDeckManager.init()
# Init the cards_ref Array
func init_cards_ref(families: Array[Family], _rules: GameRules) -> void:
	for family in families:
		for card in family.cards:
			if not _isCardInArray(card, _cards_refs):
				_cards_refs.append(card)
	
	# init dictionary
	for player_id in PlayerManager.players.keys():
		_cards_refs_displayed_in_player_shop[player_id] = []


# Construct the shop deck
func construct_shop_deck(families: Array[Family], rules: GameRules) -> void:
	if not multiplayer.is_server():
		printerr("Only the server should construct the shop deck")
		return
	
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(families, rules)
	shop_deck.shuffle()
	_is_ready = true
	shop_deck_shuffled.emit()


func put_card_back_in_cardshop(card: Card):
	#print("Putting back to the shop deck: ", card.name, " | ", card)
	if multiplayer.is_server():
		shop_deck.add_card(card.duplicate())
		return
	
	_ask_to_add_card.rpc_id(1, multiplayer.get_unique_id(), _get_card_ref_id(card))


# Draw n cards in the server shop deck
func smart_draw_n_cards(player: Player, cards_to_remove: Array[Card], number_of_cards_to_draw: int) -> Array[Card]:
	if multiplayer.is_server():
		return await _server_smart_draw_n_cards(player, cards_to_remove, number_of_cards_to_draw)
	else:
		return await _client_smart_draw_n_cards(cards_to_remove, number_of_cards_to_draw)


func try_buy_card_for_player(player: Player, card: Card) -> bool:
	if multiplayer.is_server():
		return await _server_try_buy_card_for_player(player, card)
	else:
		return await _client_try_buy_card_for_player(card)


# ============================== Private function ==============================

func _server_smart_draw_n_cards(player: Player, cards_to_remove: Array[Card], number_of_cards_to_draw: int) -> Array[Card]:
	if not _is_ready:
		await shop_deck_shuffled
	
	_cards_drawn.clear()
	var cards_to_remove_refs: Array[int]
	for card in cards_to_remove:
		cards_to_remove_refs.append(_get_card_ref_id(card))
	
	var cards_drawn = shop_deck.smart_draw_n_cards(cards_to_remove, number_of_cards_to_draw)
	var cards_drawn_refs: Array[int]
	for card in cards_drawn:
		cards_drawn_refs.append(_get_card_ref_id(card))
	
	_cards_refs_displayed_in_player_shop[player.id] = cards_drawn_refs.duplicate()
	return cards_drawn


func _client_smart_draw_n_cards(cards_to_remove: Array[Card], number_of_cards_to_draw: int) -> Array[Card]:
	_cards_drawn.clear()
	var cards_to_remove_refs: Array[int]
	for card in cards_to_remove:
		cards_to_remove_refs.append(_get_card_ref_id(card))
	
	#print("[id:", multiplayer.get_unique_id(),"] Asking the server for cards = ", _cards_drawn.size())
	_ask_to_draw_n_random_card.rpc_id(SERVER_ID, multiplayer.get_unique_id(), cards_to_remove_refs, number_of_cards_to_draw)
	await answer_for_draw_received
	#print("[id:", multiplayer.get_unique_id(),"] Got ", _cards_drawn.size(), " cards")
	#for card in _cards_drawn:
		#print("[id:", multiplayer.get_unique_id(),"] ", card.name, " - ", card.lvl)
	
	return _cards_drawn.duplicate()


func _server_try_buy_card_for_player(player: Player, card: Card) -> bool:
	var card_ref_id: int = _get_card_ref_id(card)
	
	# Check if card is in the player shop
	if card_ref_id not in _cards_refs_displayed_in_player_shop[player.id]:
		printerr("[", multiplayer.get_unique_id(),"] Peer.", player.id, " try to buy a card not displayed in his shop")
		return false
	
	# Check player money
	if player.gold < 100: # TODO check gamerules for card price
		printerr("[", multiplayer.get_unique_id(),"]  Peer.", player.id, " is not rich enough")
		return false
	
	# Put back the other cards in the shopdeck
	for card_ref_to_delete in _cards_refs_displayed_in_player_shop[player.id]:
		if card_ref_to_delete != card_ref_id:
			put_card_back_in_cardshop(_cards_refs[card_ref_to_delete])
	_cards_refs_displayed_in_player_shop[player.id].clear()
	
	PlayerManager.players[player.id].deck.add_card(_cards_refs[card_ref_id])
	PlayerManager.players[player.id].gold -= 100
	return true


func _client_try_buy_card_for_player(card: Card) -> bool:
	print("[id:", multiplayer.get_unique_id(),"] Asking the server permission to buy ", card.name)
	
	_ask_to_buy_card.rpc_id(SERVER_ID, multiplayer.get_unique_id(), _get_card_ref_id(card))
	await answer_for_buying_request_received
	
	match _server_response:
		ServerResponse.OK:
			print("[id:", multiplayer.get_unique_id(),"] OK")
			return true
		ServerResponse.NOT_ENOUGHT_MONEY:
			print("[id:", multiplayer.get_unique_id(),"] Not enought money")
			return false
		ServerResponse.CARD_NOT_BUYABLE:
			print("[id:", multiplayer.get_unique_id(),"] I can't buy this card")
			return false
	
	# Unreachable
	return false


func _isCardInArray(card_to_find: Card, cards: Array[Card]) -> bool:
	for card in cards:
		if card_to_find.name == card.name:
			return true
	
	return false


func _get_card_ref_id(card: Card) -> int:
	for i in _cards_refs.size():
		if card.name == _cards_refs[i].name:
			return i
	
	printerr("The card [", card.name, "] is not found inside the cards_ref")
	return -1

# ============================== Client RPC ==============================

@rpc("authority", "call_local")
func draw_cards(cards_refs_ids: Array[int]) -> void:
	#print("[id:", multiplayer.get_unique_id(),"] Got an answer from the server")
	_cards_drawn.clear()
	for ref_id in cards_refs_ids:
		_cards_drawn.append(_cards_refs[ref_id].duplicate())
	
	answer_for_draw_received.emit()


# Server call this rpc to notify client that a player bought a card
# emit a answer_for_buying_request_received signal
# to unlock the async try_buy_card_for_local_player() function
@rpc("authority", "call_local")
func _add_card_in_playerdeck(card_ref_id: int) -> void:
	PlayerManager.get_local_player().deck.add_card(_cards_refs[card_ref_id])
	PlayerManager.get_local_player().gold -= 100
	_server_response = ServerResponse.OK
	answer_for_buying_request_received.emit()


# Server call this to notify a client that an error occured when the server received
# a demand of buying a card from this client, it will also unlock the 
# try_buy_card_for_local_player() async function
@rpc("authority", "call_remote")
func _notify_buying_error(error: ServerResponse) -> void:
	_server_response = error
	answer_for_buying_request_received.emit()

# ============================== Server RPC ==============================

# Client call this rpc to ask the server to put back cards in the server shopdeck
# TODO check if client is not sending bullshit cards
@rpc("any_peer", "call_remote")
func _ask_to_add_card(_peer_id: int, card_ref_id: int) -> void:
	#print("[id:", multiplayer.get_unique_id(),"] Asked to add card")
	if card_ref_id < 0 or card_ref_id >= _cards_refs.size():
		printerr("Invalid card ref id")
		return
	
	if not multiplayer.is_server():
		printerr("Can only ask card to server")
		return
	
	if not _is_ready:
		await shop_deck_shuffled
	
	shop_deck.add_card(_cards_refs[card_ref_id])


# Client call this server rpc  to request the server to draw <number_of_cards_to_draw> cards from its shopdeck
# If possible, the server will draw as many cards as it can and store information about the cards draw in
# _cards_refs_displayed_in_player_shop[peer_id]. Then it will anwser the peer_id client only with an array
# of cards_ref_ids
@rpc("any_peer", "call_remote")
func _ask_to_draw_n_random_card(peer_id: int, cards_to_remove_refs: Array[int], number_of_cards_to_draw: int) -> void:
	#print("[id:", multiplayer.get_unique_id(),"] Asked to draw cards for peer ", peer_id)
	
	if not multiplayer.is_server():
		printerr("Can only ask card to server")
		return
	
	if not _is_ready:
		await shop_deck_shuffled
	
	var cards_to_remove: Array[Card]
	for ref_id in cards_to_remove_refs:
		cards_to_remove.append(_cards_refs[ref_id])
	
	var cards_drawn = shop_deck.smart_draw_n_cards(cards_to_remove, number_of_cards_to_draw)
	var cards_drawn_refs: Array[int]
	for card in cards_drawn:
		cards_drawn_refs.append(_get_card_ref_id(card))
	
	_cards_refs_displayed_in_player_shop[peer_id] = cards_drawn_refs.duplicate()
	
	var error = rpc_id(peer_id, "draw_cards", cards_drawn_refs)
	if error != OK:
		printerr("Error while calling rpc:", error)


# ClientA call this server rpc to ask the server the permission to buy a card.
# The server check if the card is one of those previously drawn by clientA.
# It will then check if ClientA has enougth money.
# If there is a problem with the buy the server notify only clientA
@rpc("any_peer", "call_remote")
func _ask_to_buy_card(peer_id: int, card_ref_id: int) -> void:
	print("[", multiplayer.get_unique_id(),"] Asked to buy a card for peer ", peer_id)
	
	if not multiplayer.is_server():
		printerr("[", multiplayer.get_unique_id(),"] Can only ask cards to server")
		return
	
	# Check if card is in the player shop
	if card_ref_id not in _cards_refs_displayed_in_player_shop[peer_id]:
		printerr("[", multiplayer.get_unique_id(),"] Peer.", peer_id, " try to buy a card not displayed in his shop")
		_notify_buying_error.rpc_id(peer_id, ServerResponse.CARD_NOT_BUYABLE)
		return
	
	# Check player money
	if PlayerManager.players[peer_id].gold < 100: # TODO check gamerules for card price
		printerr("[", multiplayer.get_unique_id(),"]  Peer.", peer_id, " is not rich enough")
		_notify_buying_error.rpc_id(peer_id, ServerResponse.NOT_ENOUGHT_MONEY)
		return
	
	# Put back the other cards in the shopdeck
	for card_ref_to_delete in _cards_refs_displayed_in_player_shop[peer_id]:
		if card_ref_to_delete != card_ref_id:
			_cards_refs_displayed_in_player_shop[peer_id].erase(card_ref_to_delete)
			put_card_back_in_cardshop(_cards_refs[card_ref_to_delete])
	
	_cards_refs_displayed_in_player_shop[peer_id].erase(card_ref_id)
	PlayerManager.players[peer_id].deck.add_card(_cards_refs[card_ref_id])
	PlayerManager.players[peer_id].gold -= 100
	_add_card_in_playerdeck.rpc_id(peer_id, card_ref_id)
