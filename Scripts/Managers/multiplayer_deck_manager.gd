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

signal answer_for_draw_received(cards_drawn_ref: Array[int])
signal shop_deck_shuffled() # Server only

# ============================== Public ==============================

var shop_deck: ShopDeck # Server only

# ============================== Private ==============================

var _cards_refs: Array[Card]
var _cards_drawn: Array[Card] # Set by the server for all
var _is_ready: bool = false # Server only

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public function ==============================

func init_cards_ref(families: Array[Family], rules: GameRules) -> void:
	for family in families:
		for card in family.cards:
			if not _isCardInArray(card, _cards_refs):
				_cards_refs.append(card)


func construct_shop_deck(families: Array[Family], rules: GameRules) -> void:
	if not multiplayer.is_server():
		printerr("Only the server should construct the shop deck")
		return
	
	print("[id:", multiplayer.get_unique_id(),"] Constructing shop deck")
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(families, rules)
	shop_deck.shuffle()
	_is_ready = true
	shop_deck_shuffled.emit()
	print("[id:", multiplayer.get_unique_id(),"] Shop deck is ready ! -> ", shop_deck.size())


func add_card(card: Card):
	if multiplayer.is_server():
		shop_deck.add_card(card.duplicate())
	
	_ask_to_add_card.rpc_id(1, _get_card_ref_id(card))


# Draw n cards in the server shop deck
func smart_draw_n_cards(cards_to_remove: Array[Card], number_of_cards_to_draw: int) -> Array[Card]:
	_cards_drawn.clear()
	print("[id:", multiplayer.get_unique_id(),"] Asking the server for cards = ", _cards_drawn.size())
	var cards_to_remove_refs: Array[int]
	for card in cards_to_remove:
		cards_to_remove_refs.append(_get_card_ref_id(card))
		print("Remove this card from shop deck: ", card.name)
	
	if multiplayer.is_server():
		return shop_deck.smart_draw_n_cards(cards_to_remove, number_of_cards_to_draw)

	_ask_to_draw_n_random_card.rpc_id(1, multiplayer.get_unique_id(), cards_to_remove_refs, number_of_cards_to_draw)
	await answer_for_draw_received
	
	print("[id:", multiplayer.get_unique_id(),"] Got ", _cards_drawn.size(), " cards")
	for card in _cards_drawn:
		print("[id:", multiplayer.get_unique_id(),"] ", card.name, " - ", card.lvl)
	
	return _cards_drawn.duplicate()
	

# ============================== Private function ==============================

func _isCardInArray(card_to_find: Card, cards: Array[Card]) -> bool:
	for card in cards:
		if card_to_find.name == card.name:
			return true
	
	return false


@rpc("any_peer", "call_local")
func _ask_to_add_card(card_ref_id: int) -> void:
	print("[id:", multiplayer.get_unique_id(),"] Asked to add card")
	if card_ref_id < 0 or card_ref_id >= _cards_refs.size():
		printerr("Invalid card ref id")
		return
	
	var card_to_add: Card = _cards_refs[card_ref_id]
	
	if not multiplayer.is_server():
		printerr("Can only ask card to server")
		return
	
	if not _is_ready:
		await shop_deck_shuffled
	
	shop_deck.add_card(_cards_refs[card_ref_id])


@rpc("any_peer", "call_local")
func _ask_to_draw_n_random_card(peer_id: int, cards_to_remove_refs: Array[int], number_of_cards_to_draw: int) -> void:
	print("[id:", multiplayer.get_unique_id(),"] Asked to draw cards for peer ", peer_id)
	
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
	
	var error = rpc_id(peer_id, "draw_cards", cards_drawn_refs)
	if error != OK:
		printerr("Error while calling rpc:", error)


@rpc("authority", "call_local")
func draw_cards(cards_refs_ids: Array[int]) -> void:
	print("[id:", multiplayer.get_unique_id(),"] Got an answer from the server")
	_cards_drawn.clear()
	for ref_id in cards_refs_ids:
		_cards_drawn.append(_cards_refs[ref_id].duplicate())
	
	answer_for_draw_received.emit()


func _get_card_ref_id(card: Card) -> int:
	for i in _cards_refs.size():
		if card.name == _cards_refs[i].name:
			return i
	
	printerr("The card [", card.name, "] is not found inside the cards_ref")
	return -1
