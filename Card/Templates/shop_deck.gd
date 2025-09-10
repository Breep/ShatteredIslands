class_name ShopDeck
extends Deck

var _available_cards: Array[Card]
var available_cards: Array[Card]: # ALL cards in card_pile + ALL cards in players shop
	get: return _available_cards

signal available_cards_composition_changed(new_family_composition: Dictionary[Family.FamilyType, int])
var available_cards_composition: Dictionary[Family.FamilyType, int] # Key=FamilyType, Value=number of cards of this family in the available cards

# ============================== Public function ==============================

func get_from_uid(uid: int) -> Card:
	for card in _card_pile:
		if card.uid == uid:
			return card
	return null

func shuffle() -> void:
	if _card_pile.is_empty():
		printerr("ShopDeck: Trying to shuffle an empty card pile")
		return
	
	for i in _card_pile.size():
		var random_index =  Utils.rng.randi_range(0, _card_pile.size() - 1)
		var temp = _card_pile[i]
		_card_pile[i] = _card_pile[random_index]
		_card_pile[random_index] = temp


func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	_card_pile.clear()
	var uid: int = 0
	for family in families:
		for card in family.cards:
			var number_of_cards_to_add: int
			match card.rarity:
				Card.Rarity.COMMON: number_of_cards_to_add = game_rules.common_number
				Card.Rarity.RARE: number_of_cards_to_add = game_rules.rare_number
				Card.Rarity.EPIC: number_of_cards_to_add = game_rules.epic_number
			for i in number_of_cards_to_add:
				var ucard: Card = card.duplicate()
				ucard.uid = uid
				uid += 1
				add_card(ucard)
	_available_cards = _card_pile.duplicate()
	_update_available_cards_composition(_available_cards, [])


#TODO Add check on family level
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
	for card in new_cards:
		if available_cards_composition.has(card.family):
			available_cards_composition[card.family] += 1
		else:
			available_cards_composition[card.family] = 1
	
	for card in removed_cards:
		available_cards_composition[card.family] -= 1
	
	available_cards_composition_changed.emit(available_cards_composition)
