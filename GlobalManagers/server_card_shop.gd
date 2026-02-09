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

# [Server only]
# Pool de cartes disponibles par joueur, organisé par rareté uniquement
# Permet un tirage O(1) une fois la rareté déterminée
var _player_available_pool: Dictionary[int, Dictionary] # Dictionary[Card.Rarity, Array[Card]]
# {
#   player_id_1: {
#     COMMON: [Card, Card, Card, ...],
#     RARE: [Card, Card, ...],
#     EPIC: [Card, ...],
#     LEGENDARY: [Card, Card, Card]
#   },
#   player_id_2: { ... }
# }

# [Server only] Dictionary of all cards distributed in all player shop
var _cards_in_player_shop: Dictionary[int, Array] # { player_id, Array[Card] }

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
# Calling ServerCardShop is different from client and server as there are multiple players at the same time on the server (1 human + n bots)

func try_refresh_shop_for_player(player: Player, is_free: bool) -> Array[Card]:
	Verbose.trace("try_refresh_shop_for_player() | " + player.name + " | " + str(is_free), Verbose.Category.CARD_SHOP)
	if multiplayer.is_server():
		return await _server_try_refresh_shop_for_player(player, is_free)
	else:
		return await _client_try_refresh_shop_for_player(is_free)


func try_buy_card_from_player_shop(player: Player, card: Card) -> bool:
	Verbose.trace("try_buy_card_from_player_shop() | " + player.name + " | " + card.name, Verbose.Category.CARD_SHOP)
	if multiplayer.is_server():
		return _server_try_buy_card_from_player_shop(player, card)
	else:
		return await _client_try_buy_card_from_player_shop(card)


func try_buy_random_card_for_player(player: Player) -> Card:
	Verbose.trace("try_buy_random_card_for_player() | " + player.name, Verbose.Category.CARD_SHOP)
	if multiplayer.is_server():
		return _server_try_buy_random_card_for_player(player)
	else:
		return await _client_try_buy_random_card_for_player()

# Remet toutes les cartes d'un joueur éliminé dans le pool
func return_player_cards_to_pool(player: Player) -> void:
	var cards_to_return: Array[Card] = player.deck.get_cards_raw()
	for card in cards_to_return:
		# Remettre la carte au niveau 1
		var base_card: Card = card.duplicate()
		base_card.lvl = 1
		# Ajouter au pool global
		shop_deck.add_card(base_card)
		# Mettre à jour les pools de tous les joueurs vivants
	for player_id in _player_available_pool.keys():
		if PlayerManager.players[player_id].is_alive:
			_player_available_pool[player_id] = _build_player_available_pool(PlayerManager.players[player_id])

# ============================== Private function ==============================

# ========== INIT SERVER CARD SHOP

func _init_cards_in_player_shop() -> void:
	Verbose.trace("INIT CARDS IN PLAYER SHOP -> " + str(PlayerManager.players.keys()), Verbose.Category.CARD_SHOP)
	for player_id in PlayerManager.players.keys():
		_cards_in_player_shop[player_id] = []
		_player_available_pool[player_id] = _build_player_available_pool(PlayerManager.players[player_id])
		PlayerManager.players[player_id].deck.family_leveled_up.connect(_on_player_family_leveled_up)


func _construct_shop_deck(families: Array[Family], rules: GameRules) -> void:
	Verbose.trace("_construct_shop_deck() | " + str(families.size()), Verbose.Category.CARD_SHOP)
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(families, rules)
	_is_ready = true
	_shop_deck_shuffled.emit()

# ========== DRAW

func _server_draw_n_cards(player: Player, number_of_cards_to_draw: int) -> Array[Card]:
	Verbose.trace("_server_draw_n_cards() | " + player.name + " | " + str(number_of_cards_to_draw), Verbose.Category.CARD_SHOP)
	if not _is_ready: await _shop_deck_shuffled
	var cards_drawn = shop_deck.draw_cards_for_player(player, number_of_cards_to_draw, _player_available_pool[player.id])
	for card in cards_drawn:
		for available_cards in _player_available_pool.values():
			available_cards[card.rarity].erase(card)
	
	return cards_drawn

# ========== BUY A CARD FROM PLAYER CARD SHOP

func _server_try_buy_card_from_player_shop(player: Player, card_to_buy: Card) -> bool:
	Verbose.trace("_server_try_buy_card_from_player_shop() | " + player.name + " | " + card_to_buy.name, Verbose.Category.CARD_SHOP)
	if not card_to_buy in _cards_in_player_shop[player.id]:
		Verbose.error("Peer." + str(player.id) + " tries to buy a card not displayed in his shop [" + card_to_buy.name + "]", Verbose.Category.CARD_SHOP)
		return false
	
	if player.gold < 100: # TODO check gamerules for card price
		Verbose.warn("Peer." + str(player.id) + " is not rich enough", Verbose.Category.CARD_SHOP)
		return false
	
	_cards_in_player_shop[player.id].erase(card_to_buy)
	player.deck.add_card(card_to_buy)
	player.gold -= 100
	shop_deck.remove_from_available_cards(card_to_buy)
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
			Verbose.warn("ServerCardShop: Not enought money", Verbose.Category.CARD_SHOP)
			return false
		ServerResponse.CARD_NOT_BUYABLE:
			Verbose.error("ServerCardShop: I can't buy this card [" + card.name + "]", Verbose.Category.CARD_SHOP)
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
	shop_deck.remove_from_available_cards(card_to_buy)
	_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.OK)


@rpc("authority", "call_remote", "reliable")
func _answer_buy_card_from_player_shop(server_response: ServerResponse) -> void:
	Verbose.trace("_answer_buy_card_from_player_shop() | " + str(server_response), Verbose.Category.CARD_SHOP)
	_server_response = server_response
	_answer_for_buying_request_received.emit()

# ========== BUY RANDOM CARD

func _server_try_buy_random_card_for_player(player: Player) -> Card:
	Verbose.trace("_server_try_buy_random_card_for_player() | " + player.name)
	if player.gold < 90:
		Verbose.warn("ServerCardShop: (" + player.name + ") Not enought money", Verbose.Category.CARD_SHOP)
		return null
	var cards: Array[Card] = shop_deck.draw_cards_for_player(player, 1, _player_available_pool[player.id])
	if cards.is_empty():
		Verbose.warn("ServerCardShop: (" + player.name + ") No more random card from the server", Verbose.Category.CARD_SHOP)
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
			Verbose.warn("ServerCardShop: Not enought money", Verbose.Category.CARD_SHOP)
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
	var cards: Array[Card] = shop_deck.draw_cards_for_player(player, 1, _player_available_pool[player.id])
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
	Verbose.trace("_server_try_refresh_shop_for_player() | " + player.name + " | " + str(is_free), Verbose.Category.CARD_SHOP)
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

func _build_player_available_pool(player: Player) -> Dictionary[Card.Rarity, Array]:
	var player_pool: Dictionary[Card.Rarity, Array] = {}
	
	# Parcourir toutes les familles actives
	for family in _families:
		var family_type: Family.FamilyType = family.family_type
		
		# Calculer le niveau du joueur dans cette famille
		var family_points: int = player.deck.get_family_points(family_type)
		var family_level: int = _game_rules.get_family_level(family_points)
		
		# Récupérer les raretés débloquées
		var locked_rarities: Array[Card.Rarity] = _game_rules.get_locked_rarities(family_level)
		
		# Ajouter les cartes de cette famille aux raretés débloquées
		for rarity in shop_deck.get_rarities_for_family(family_type):
			# Ignorer les raretés verrouillées
			if rarity in locked_rarities:
				continue
			
			# Initialiser l'array pour cette rareté
			if not player_pool.has(rarity):
				player_pool[rarity] = []
			
			# Ajouter toutes les cartes de cette famille/rareté
			# (on ne copie QUE les références, pas les objets)
			player_pool[rarity].append_array(shop_deck.get_cards_for_rarity_for_family(family_type, rarity))
	
	# Retirer les cartes déjà au niveau max pour ce joueur
	_remove_max_level_cards_from_pool(player, player_pool)
	
	return player_pool

func _remove_max_level_cards_from_pool(player: Player, player_pool: Dictionary[Card.Rarity, Array]) -> void:
	var max_lvl_cards: Array[Card] = player.deck.get_max_lvl_cards()
	for max_card in max_lvl_cards:
		for rarity in player_pool.keys():
			var i: int = player_pool[rarity].size() - 1
			while i >= 0:
				if player_pool[rarity][i].name == max_card.name:
					player_pool[rarity].remove_at(i)
					i -= 1

func _on_player_family_leveled_up(player: Player, family_type: Family.FamilyType, new_level: int) -> void:
	Verbose.debug("%s leveled up %s to %d" % [player.name, family_type, new_level], Verbose.Category.CARD_SHOP)
	
	# Reconstruire le pool du joueur pour inclure les nouvelles raretés
	_player_available_pool[player.id] = _build_player_available_pool(player)
