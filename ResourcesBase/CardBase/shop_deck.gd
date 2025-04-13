class_name ShopDeck
extends Deck


var _available_cards: Array[Card]
var available_cards: Array[Card]: # ALL cards in card_pile + ALL cards in players shop
	get: return _available_cards

signal available_cards_composition_changed(new_family_composition: Dictionary[Family.FamilyType, int])
var available_cards_composition: Dictionary[Family.FamilyType, int] # Key=FamilyType, Value=number of cards of this family in the available cards

# ============================== Public function ==============================

func shuffle() -> void:
	if _card_pile.is_empty():
		printerr("Trying to shuffle an empty card pile")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in _card_pile.size():
		var random_index =  rng.randi_range(0, _card_pile.size() - 1)
		var temp = _card_pile[i]
		_card_pile[i] = _card_pile[random_index]
		_card_pile[random_index] = temp


func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	_card_pile.clear()
	for family in families:
		for card in family.cards:
			match card.rarity:
				Card.Rarity.COMMON:
					for i in game_rules.common_number:
						add_card(card.duplicate())
				Card.Rarity.RARE:
					for i in game_rules.rare_number:
						add_card(card.duplicate())
				Card.Rarity.EPIC:
					for i in game_rules.epic_number:
						add_card(card.duplicate())
	_available_cards = _card_pile.duplicate()
	_update_available_cards_composition(_available_cards, [])


func smart_draw_n_cards(cards_to_remove: Array[Card], number_of_cards_to_draw: int):
	#print("Remaining cards in shop deck: ", size())
	var card_pile_copy = _card_pile.duplicate()
	for card_to_remove in cards_to_remove:
		_remove_all_same_card_in_array(card_to_remove, card_pile_copy)
	var cardsToDraw: Array[Card] = _draw_n_random_card_in_array(number_of_cards_to_draw, card_pile_copy)
	for drawcard in cardsToDraw:
		remove_card(drawcard)
	return cardsToDraw


func debug_print() -> void:
	var card_types_number_dictionary: Dictionary
	for card in _card_pile:
		if card_types_number_dictionary.has(card.name):
			card_types_number_dictionary[card.name] += 1
		else:
			card_types_number_dictionary[card.name] = 1
	
	for card_name in card_types_number_dictionary.keys():
		print(card_name, " : ", card_types_number_dictionary[card_name])


func remove_from_available_cards(card_to_remove: Card) -> void:
	_update_available_cards_composition([], [card_to_remove])

# ============================== Private function ==============================

func _update_available_cards_composition(new_cards: Array[Card], removed_cards: Array[Card]) -> void:
	print("_update_available_cards_composition")
	for card in new_cards:
		if available_cards_composition.has(card.families[0]):
			available_cards_composition[card.families[0]] += 1
		else:
			available_cards_composition[card.families[0]] = 1
	
	for card in removed_cards:
		available_cards_composition[card.families[0]] -= 1
	
	available_cards_composition_changed.emit(available_cards_composition)
