class_name ShopDeck
extends Deck

signal available_cards_composition_changed(new_family_composition: Dictionary[Family.FamilyType, int])
var available_cards_composition: Dictionary[Family.FamilyType, int] # Key=FamilyType, Value=number of cards of this family in the available cards

# Structure principale : accès direct par famille et rareté
var _global_card_pool: Dictionary[Family.FamilyType, Dictionary] # Dictionary[Card.Rarity, Array[Card]]

# ============================== Public function ==============================

func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	Verbose.debug("Constructing shop deck | " + str(families.size()), Verbose.Category.SHOP_DECK)
	_card_pile.clear()
	var uid: int = 0
	var total_cards_added: int = 0
	for family in families:
		var family_type: Family.FamilyType = family.family_type
		_global_card_pool[family_type] = {}
		var total_family_cards_added: int = 0
		Verbose.trace("Constructing family: " + str(family.family_name), Verbose.Category.SHOP_DECK)
		for card in family.cards:
			var rarity: Card.Rarity = card.rarity
			var number_of_cards_to_add: int = game_rules.rarity_card_numbers[rarity]
			
			if not _global_card_pool[family_type].has(rarity):
				_global_card_pool[family_type][rarity] = []
			
			for i in number_of_cards_to_add:
				var ucard: Card = card.duplicate()
				ucard.uid = uid
				ucard.lvl = 1
				uid += 1
				add_card(ucard)
				total_family_cards_added += 1
		Verbose.trace("Family: " + str(family.family_name) + " constructed | " + str(total_family_cards_added), Verbose.Category.SHOP_DECK)
		total_cards_added += total_family_cards_added
	Verbose.debug("Shop deck constructed | total cards = " + str(total_cards_added), Verbose.Category.SHOP_DECK)
	_update_available_cards_composition(_card_pile.values(), [])


func draw_n_cards(number_of_cards_to_draw: int, player_deck: PlayerDeck = null) -> Array[Card]:
	if player_deck == null:
		return _legacy_draw_n_card(number_of_cards_to_draw)
	else:
		return _smart_draw_n_card(number_of_cards_to_draw, player_deck)


func remove_from_available_cards(card_to_remove: Card) -> void:
	_update_available_cards_composition([], [card_to_remove])

func get_rarities_for_family(family_type: Family.FamilyType) -> Array:
	return _global_card_pool.get(family_type, {}).keys()

func get_cards_for_rarity_for_family(family_type: Family.FamilyType, card_rarity: Card.Rarity) -> Array:
	if _global_card_pool.has(family_type):
		return _global_card_pool[family_type].get(card_rarity, [])
	return []


# Tire N cartes pour un joueur en respectant les probabilités
func draw_cards_for_player(player: Player, count: int, player_available_pool: Dictionary[Card.Rarity, Array]) -> Array[Card]:
	var drawn_cards: Array[Card] = []
	var already_drawn_names: Array[String] = [] # Éviter les doublons dans le shop
	
	# Calculer le niveau max du joueur parmi toutes les familles
	var max_family_level: int = _get_player_max_family_level(player)
	
	for i in count:
		# ÉTAPE 1 : Tirer la rareté selon les probabilités
		var rarity: Card.Rarity = _roll_rarity(max_family_level)
		
		# ÉTAPE 2 : Filtrer les cartes disponibles
		var available_cards: Array[Card] = []
		if player_available_pool.has(rarity):
			for card in player_available_pool[rarity]:
				# Éviter les doublons dans le shop
				if not card.name in already_drawn_names:
					available_cards.append(card)
		
		# Si aucune carte disponible pour cette rareté, essayer la rareté inférieure
		if available_cards.is_empty():
			rarity = _get_fallback_rarity(rarity, player_available_pool)
			if rarity != Card.Rarity.COMMON: # Retry avec la nouvelle rareté
				available_cards = player_available_pool.get(rarity, []).filter(
					func(c): return not c.name in already_drawn_names
				)
		
		# Si toujours rien, arrêter le tirage
		if available_cards.is_empty():
			Verbose.warn("No more cards available for player %s" % player.name, Verbose.Category.CARD_SHOP)
			break
		
		# ÉTAPE 3 : Tirer une carte aléatoire
		var random_index: int = Utils.rng.randi_range(0, available_cards.size() - 1)
		var drawn_card: Card = available_cards[random_index]
		
		# ÉTAPE 4 : Ajouter à la liste des tirées
		drawn_cards.append(drawn_card)
		already_drawn_names.append(drawn_card.name)
	
	return drawn_cards

# ============================== Private function ==============================

func _update_available_cards_composition(new_cards: Array[Card], removed_cards: Array[Card]) -> void:
	for card in new_cards:
		if available_cards_composition.has(card.families[0]):
			available_cards_composition[card.families[0]] += 1
		else:
			available_cards_composition[card.families[0]] = 1
	
	for card in removed_cards:
		available_cards_composition[card.families[0]] -= 1
	
	available_cards_composition_changed.emit(available_cards_composition)


# Draw n cards in the deck but first:
# - Remove all cards already at max level in the player_deck
# - Remove all cards from rarity level not unlocked (TODO)
func _smart_draw_n_card(number_of_cards_to_draw: int, player_deck: PlayerDeck) -> Array[Card]:
	var card_pile_values_duplicate: Array[Card] = _card_pile.values().duplicate()
	for card_to_remove in player_deck.get_max_lvl_cards():
		_remove_all_same_card_in_array(card_to_remove, card_pile_values_duplicate)
	_remove_locked_cards(player_deck, card_pile_values_duplicate)
	var cards_drawn: Array[Card] = _draw_n_random_different_cards_in_array(number_of_cards_to_draw, card_pile_values_duplicate)
	for card in cards_drawn:
		_card_pile.erase(card.uid)
	return cards_drawn


func _remove_locked_cards(player_deck: PlayerDeck, cards: Array[Card]) -> void:
	for family: Family in GameManager.active_families:
		var player_family_points: int = player_deck.get_family_points(family.family_type)
		var player_family_level: int = GameManager.game_rules.get_family_level(player_family_points)
		var locked_rarities: Array[Card.Rarity] = GameManager.game_rules.get_locked_rarities(player_family_level)
		var cards_locked: Array[Card] = _get_all_cards_of_rarities_of_family_type(locked_rarities, family.family_type, cards)
		for card_to_remove in cards_locked:
			_remove_all_same_card_in_array(card_to_remove, cards)

# Calcule le niveau max parmi toutes les familles du joueur
func _get_player_max_family_level(player: Player) -> int:
	var max_level: int = 0
	for family in GameManager.active_families:
		var points: int = player.deck.get_family_points(family.family_type)
		var level: int = GameManager.game_rules.get_family_level(points)
		if level > max_level:
			max_level = level
	return max_level


# Tire une rareté selon les probabilités du niveau
func _roll_rarity(family_level: int) -> Card.Rarity:
	var roll: float = Utils.rng.randf_range(0.0, 100.0)
	var thresholds: Dictionary = _drop_rate_to_threshold(GameManager.game_rules.drop_rates_by_family_level[family_level])
	
	# Comparaison avec seuils cumulés
	if roll < thresholds.get(Card.Rarity.COMMON, 100):
		return Card.Rarity.COMMON
	elif roll < thresholds.get(Card.Rarity.RARE, 100.0):
		return Card.Rarity.RARE
	elif roll < thresholds.get(Card.Rarity.EPIC, 100.0):
		return Card.Rarity.EPIC
	else:
		return Card.Rarity.LEGENDARY


# Trouve une rareté de repli si la pool est vide
func _get_fallback_rarity(rarity: Card.Rarity, pool: Dictionary[Card.Rarity, Array]) -> Card.Rarity:
	var fallback_order: Array[Card.Rarity] = [
		Card.Rarity.LEGENDARY,
		Card.Rarity.EPIC,
		Card.Rarity.RARE,
		Card.Rarity.COMMON
	]
	
	var start_index: int = fallback_order.find(rarity)
	for i in range(start_index + 1, fallback_order.size()):
		var fallback_rarity: Card.Rarity = fallback_order[i]
		if pool.has(fallback_rarity) and not pool[fallback_rarity].is_empty():
			return fallback_rarity
	return Card.Rarity.COMMON

func _drop_rate_to_threshold(drop_rates: Dictionary[Card.Rarity, float]) -> Dictionary[Card.Rarity, float]:
	var thresholds: Dictionary[Card.Rarity, float]
	thresholds[Card.Rarity.COMMON] = drop_rates[Card.Rarity.COMMON]
	thresholds[Card.Rarity.RARE] = thresholds[Card.Rarity.COMMON] + drop_rates[Card.Rarity.RARE]
	thresholds[Card.Rarity.EPIC] = thresholds[Card.Rarity.RARE] + drop_rates[Card.Rarity.EPIC]
	thresholds[Card.Rarity.LEGENDARY] = thresholds[Card.Rarity.EPIC] + drop_rates[Card.Rarity.LEGENDARY]
	return thresholds

func _remove_card_from_global_pool(card: Card) -> void:
	if not _card_pile.has(card.uid):
		printerr("ShopDeck: Card UID %d not found in index" % card.uid)
		return
	var indexed_card: Card = _card_pile[card.uid]
	var family_type: Family.FamilyType = indexed_card.families[0]
	var rarity: Card.Rarity = indexed_card.rarity
	# Supprimer du pool global
	if _global_card_pool.has(family_type) and _global_card_pool[family_type].has(rarity):
		_global_card_pool[family_type][rarity].erase(indexed_card)
	# Supprimer de l'index
	_card_pile.erase(card.uid)
	# Mettre à jour les compteurs
	#_total_cards_count -= 1
	#_cards_count_by_rarity[rarity] -= 1

func _specific_add(card_to_add: Card) -> void:
	var family_type: Family.FamilyType = card_to_add.families[0]
	var rarity: Card.Rarity = card_to_add.rarity
	_global_card_pool[family_type][rarity].append(card_to_add)
