class_name ShopDeck
extends Deck

class CardsArray extends RefCounted:
	var cards: Array[Card]
	
	func _init() -> void:
		cards = []

class CardPool extends RefCounted:
	var pool: Dictionary[Card.Rarity, CardsArray]
	
	func add_card(card: Card) -> void:
		if not pool.has(card.rarity): return
		pool[card.rarity].cards.append(card)
	
	func remove_card(card: Card) -> void:
		if not pool.has(card.rarity): return
		pool[card.rarity].cards.erase(card)

class PlayerPool extends CardPool:
	var _player: Player
	var _families: Array[Family]
	var _game_rules: GameRules
	var _shop_deck: ShopDeck
	
	func _init(player: Player, families: Array[Family], game_rules: GameRules, shop_deck: ShopDeck) -> void:
		_player = player
		_families = families
		_game_rules = game_rules
		_shop_deck = shop_deck
		_player.deck.family_leveled_up.connect(_on_family_leveled_up)
		_player.deck.card_maxed.connect(_on_card_maxed)
		
	func build() -> PlayerPool:
		for family in _families:
			var family_type: Family.FamilyType = family.family_type
			var family_points: int = _player.deck.get_family_points(family_type)
			var family_level: int = _game_rules.get_family_level(family_points)
			var locked_rarities: Array[Card.Rarity] = _game_rules.get_locked_rarities(family_level)
			for rarity in _shop_deck.get_rarities_for_family(family_type):
				if rarity in locked_rarities:
					continue
				if not pool.has(rarity):
					pool[rarity] = CardsArray.new()
				pool[rarity].cards.append_array(_shop_deck.get_cards_for_rarity_for_family(family_type, rarity))	
		return self
		
	func update(family_type: Family.FamilyType, rarity: Card.Rarity) -> void:
		if not pool.has(rarity):
			pool[rarity] = CardsArray.new()
		pool[rarity].cards.append_array(_shop_deck.get_cards_for_rarity_for_family(family_type, rarity))
		return
	
	
	func add_card(card: Card) -> void:
		if not pool.has(card.rarity): return
		pool[card.rarity].cards.append(card)
	
	
	func remove_card(card: Card) -> void:
		if not pool.has(card.rarity): return
		pool[card.rarity].cards.erase(card)
	
	
	func _on_card_maxed(card: Card) -> void:
		Verbose.debug("%s is maxed" % [card.name], Verbose.Category.CARD_SHOP)
		var i: int = pool[card.rarity].cards.size() - 1
		while i >= 0:
			if pool[card.rarity].cards[i].name == card.name:
				pool[card.rarity].cards.remove_at(i)
			i -= 1
	
	
	func _on_family_leveled_up(family_type: Family.FamilyType, new_level: int) -> void:
		Verbose.debug("%s leveled up %s to %d" % [_player.name, family_type, new_level], Verbose.Category.CARD_SHOP)
		if _game_rules.card_rarity_unlocked_by_level.has(new_level):
			var rarity_unlocked: Card.Rarity = _game_rules.card_rarity_unlocked_by_level[new_level]
			update(family_type, rarity_unlocked)
	

var _player_available_pools: Dictionary[Player, PlayerPool]

signal available_cards_composition_changed(new_family_composition: Dictionary[Family.FamilyType, int])
var available_cards_composition: Dictionary[Family.FamilyType, int] # Key=FamilyType, Value=number of cards of this family in the available cards

# Structure principale : accès direct par famille et rareté
var _global_card_pools: Dictionary[Family.FamilyType, CardPool] # Dictionary[Card.Rarity, Array[Card]]

# ============================== Public function ==============================

#func toto() -> void:
	#var _player_pool = PlayerPool.new(player, families, game_rules, shop_deck)

func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	Verbose.debug("Constructing shop deck | " + str(families.size()), Verbose.Category.SHOP_DECK)
	_card_pile.clear()
	var uid: int = 0
	var total_cards_added: int = 0
	for family in families:
		var family_type: Family.FamilyType = family.family_type
		_global_card_pools[family_type] = CardPool.new()
		var total_family_cards_added: int = 0
		Verbose.trace("Constructing family: " + str(family.family_name), Verbose.Category.SHOP_DECK)
		for card in family.cards:
			var rarity: Card.Rarity = card.rarity
			var number_of_cards_to_add: int = game_rules.rarity_card_numbers[rarity]
			
			if not _global_card_pools[family_type].pool.has(rarity):
				_global_card_pools[family_type].pool[rarity] = CardsArray.new()
			
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
	_init_player_pools(families, game_rules)

func get_rarities_for_family(family_type: Family.FamilyType) -> Array:
	return _global_card_pools[family_type].pool.keys()

func get_cards_for_rarity_for_family(family_type: Family.FamilyType, card_rarity: Card.Rarity) -> Array:
	if _global_card_pools.has(family_type) and _global_card_pools[family_type].pool.has(card_rarity):
		return _global_card_pools[family_type].pool[card_rarity].cards
	return []

# Tire N cartes pour un joueur en respectant les probabilités
func draw_cards_for_player(player: Player, count: int) -> Array[Card]:
	var player_available_pool: PlayerPool = _player_available_pools[player]
	var drawn_cards: Array[Card] = []
	var already_drawn_names: Array[String] = [] # Éviter les doublons dans le shop
	
	# Calculer le niveau max du joueur parmi toutes les familles
	var max_family_level: int = _get_player_max_family_level(player)
	
	for i in count:
		# ÉTAPE 1 : Tirer la rareté selon les probabilités
		var rarity: Card.Rarity = _roll_rarity(max_family_level)
		
		# ÉTAPE 2 : Filtrer les cartes disponibles
		var available_cards: Array[Card] = []
		if player_available_pool.pool.has(rarity):
			for card in player_available_pool.pool[rarity].cards:
				# Éviter les doublons dans le shop
				if not card.name in already_drawn_names:
					available_cards.append(card)
		
		# Si aucune carte disponible pour cette rareté, essayer la rareté inférieure
		if available_cards.is_empty():
			if rarity != Card.Rarity.COMMON:
				# Retry avec la nouvelle rareté
				rarity = _get_fallback_rarity(rarity, player_available_pool)
				for card in player_available_pool.pool[rarity].cards:
					if not card.name in already_drawn_names:
						available_cards.append(card)
		
		# Si toujours rien, arrêter le tirage
		if available_cards.is_empty():
			Verbose.warn("No more cards available for player %s" % player.player_name, Verbose.Category.CARD_SHOP)
			break
		
		# ÉTAPE 3 : Tirer une carte aléatoire
		var random_index: int = Utils.get_randi_range(0, available_cards.size() - 1)
		var drawn_card: Card = available_cards[random_index]
		
		# ÉTAPE 4 : Ajouter à la liste des tirées
		drawn_cards.append(drawn_card)
		already_drawn_names.append(drawn_card.name)
	for card in drawn_cards:
		remove_card(card)
		
	return drawn_cards

func add_card(card_to_add: Card) -> void:
	super.add_card(card_to_add)
	var family_type: Family.FamilyType = card_to_add.families[0]
	_global_card_pools[family_type].add_card(card_to_add)
	for pool: PlayerPool in _player_available_pools.values():
		pool.add_card(card_to_add)

func remove_card(card_to_remove: Card) -> void:
	super.remove_card(card_to_remove)
	var family_type: Family.FamilyType = card_to_remove.families[0]
	_global_card_pools[family_type].remove_card(card_to_remove)
	for pool: PlayerPool in _player_available_pools.values():
		pool.remove_card(card_to_remove)

# ============================== Private function ==============================

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
	var roll: float = Utils.get_randf_range(0.0, 100.0)
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
func _get_fallback_rarity(rarity: Card.Rarity, player_pool: PlayerPool) -> Card.Rarity:
	var fallback_order: Array[Card.Rarity] = [
		Card.Rarity.LEGENDARY,
		Card.Rarity.EPIC,
		Card.Rarity.RARE,
		Card.Rarity.COMMON
	]
	
	var start_index: int = fallback_order.find(rarity)
	for i in range(start_index + 1, fallback_order.size()):
		var fallback_rarity: Card.Rarity = fallback_order[i]
		if player_pool.pool.has(fallback_rarity) and not player_pool.pool[fallback_rarity].cards.is_empty():
			return fallback_rarity
	return Card.Rarity.COMMON

func _drop_rate_to_threshold(drop_rates: Dictionary) -> Dictionary[Card.Rarity, float]:
	var thresholds: Dictionary[Card.Rarity, float]
	thresholds[Card.Rarity.COMMON] = drop_rates[Card.Rarity.COMMON]
	thresholds[Card.Rarity.RARE] = thresholds[Card.Rarity.COMMON] + drop_rates[Card.Rarity.RARE]
	thresholds[Card.Rarity.EPIC] = thresholds[Card.Rarity.RARE] + drop_rates[Card.Rarity.EPIC]
	thresholds[Card.Rarity.LEGENDARY] = thresholds[Card.Rarity.EPIC] + drop_rates[Card.Rarity.LEGENDARY]
	return thresholds

func _init_player_pools(families: Array[Family], game_rules: GameRules) -> void:
	for player in PlayerManager.get_alive_players().values():
		_player_available_pools[player] = PlayerPool.new(player, families, game_rules, self).build()
		
		
		
