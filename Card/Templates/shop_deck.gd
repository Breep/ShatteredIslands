class_name ShopDeck
extends Deck

signal available_cards_composition_changed(new_family_composition: Dictionary[Family.FamilyType, int])
var available_cards_composition: Dictionary[Family.FamilyType, int] # Key=FamilyType, Value=number of cards of this family in the available cards

# ============================== Public function ==============================

func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	Verbose.debug("Constructing shop deck | " + str(families.size()), Verbose.Category.SHOP_DECK)
	_card_pile.clear()
	var uid: int = 0
	var total_cards_added: int = 0
	for family in families:
		var total_family_cards_added: int = 0
		Verbose.trace("Constructing family: " + str(family.family_name), Verbose.Category.SHOP_DECK)
		for card in family.cards:
			var number_of_cards_to_add: int
			match card.rarity:
				Card.Rarity.COMMON: number_of_cards_to_add = game_rules.common_number
				Card.Rarity.RARE: number_of_cards_to_add = game_rules.rare_number
				Card.Rarity.EPIC: number_of_cards_to_add = game_rules.epic_number
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













 
