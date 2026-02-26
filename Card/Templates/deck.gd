class_name Deck
extends Resource

# ============================== Public variables ==============================

var _card_pile: Dictionary[int, Card]

var _families_count: Dictionary[Family.FamilyType, int]
var families_count: Dictionary[Family.FamilyType, int]:
	get: return _families_count

# ============================== Public functions ==============================

func get_card(uid: int) -> Card:
	return _card_pile[uid] if _card_pile.has(uid) else null

func get_cards_raw() -> Array[Card]:
	return _card_pile.values()

func add_card(card_to_add: Card) -> void:
	if card_to_add == null:
		printerr("Deck: Can't add a null card inside the card_pile")
	else:
		if _card_pile.has(card_to_add.uid):
			printerr("Deck: Adding an already existing card into a deck [", card_to_add.uid, "-", card_to_add.name, "]")
			return
		_card_pile[card_to_add.uid] = card_to_add
		if _families_count.has(card_to_add.families[0]):
			_families_count[card_to_add.families[0]] += 1
		else:
			_families_count[card_to_add.families[0]] = 1


func remove_card(card_to_remove: Card) -> void:
	if card_to_remove == null:
		printerr("Can't remove a null card")
	elif card_to_remove in _card_pile.values():
		_card_pile.erase(card_to_remove.uid)
		if _families_count.has(card_to_remove.families[0]):
			_families_count[card_to_remove.families[0]] -= 1


func size():
	return _card_pile.size()

# ============================== Private functions ==============================

func _remove_all_same_card_in_array(card_to_remove: Card, cards: Array[Card]) -> void:
	if card_to_remove == null:
		printerr("Can't remove a null card")
		return
	
	var cards_duplicated: Array[Card] = cards.duplicate()
	for card in cards_duplicated:
		if card.name == card_to_remove.name:
			cards.erase(card)


func _remove_card_at_pos_in_array(index: int, cards: Array[Card]) -> void:
	if index >= 0 and index < cards.size():
		cards.remove_at(index)
	else:
		printerr("Invalid index :", index)


func _draw_card_in_array(index: int, cards: Array[Card]) -> Card:
	if cards.is_empty():
		printerr("Deck: Trying to draw a card in an empty deck.")
		return null
	
	if index >= 0 and index < cards.size():
		var drawn_card: Card = cards[index]
		_remove_card_at_pos_in_array(index, cards)
		return drawn_card
	else:
		printerr("Deck: Invalid index", index)
		return null


func _draw_random_card_in_array(cards: Array[Card]) -> Card:
	if cards.is_empty():
		printerr("The card_pile is empty. Cannot draw a card.")
		return null
	
	var random_index = Utils.get_randi_range(0, cards.size() - 1)
	return _draw_card_in_array(random_index, cards)


 #TODO Improve this function to accept a draw chance rule (like 50% chance common, 30% chance rare, 20% chance epic)
func _draw_n_random_different_cards_in_array(number_of_cards_to_draw :int, cards: Array[Card]) -> Array[Card]:
	if cards.is_empty():
		printerr("The card_pile is empty. Cannot draw cards.")
		return []
	
	if number_of_cards_to_draw > _get_diffent_cards_number_in_array(cards):
		number_of_cards_to_draw = _get_diffent_cards_number_in_array(cards)
	
	var returned_cards: Array[Card] = []
	var cards_duplicate = cards.duplicate()
	while returned_cards.size() < number_of_cards_to_draw:
		var randomCard = _draw_random_card_in_array(cards_duplicate)
		_remove_all_same_card_in_array(randomCard, cards_duplicate)
		returned_cards.append(randomCard)
	
	return returned_cards


func _get_array_with_no_duplicate(cards: Array) -> Array:
	var unique_cards: Array[Card] = []
	for card in cards:
		if not _is_card_in_array(card, unique_cards):
			unique_cards.append(card)
	
	return unique_cards


# A card_pile with {A,A,A,B,C,C,C,C,C,D,E,E,E} will return 5
func _get_diffent_cards_number_in_array(cards: Array[Card]) -> int:
	return _get_array_with_no_duplicate(cards).size()


func _is_card_in_array(card_to_find: Card, cards: Array[Card]) -> bool:
	for card in cards:
		if card_to_find.name == card.name:
			return true
	
	return false


func _legacy_draw_n_card(number_of_cards_to_draw: int) -> Array[Card]:
	var card_pile_values_duplicate: Array[Card] = _card_pile.values().duplicate()
	var cards_drawn: Array[Card] = _draw_n_random_different_cards_in_array(number_of_cards_to_draw, card_pile_values_duplicate)
	for card in cards_drawn:
		_card_pile.erase(card.uid)
	return cards_drawn


func _get_all_cards_of_rarity(rarity: Card.Rarity, family_type: Family.FamilyType, cards: Array[Card]) -> Array[Card]:
	var cards_matching_rarity: Array[Card]
	for card: Card in cards:
		if card.families[0] == family_type and card.rarity == rarity:
			cards_matching_rarity.append(card)
	return cards_matching_rarity


func _get_all_cards_of_rarities_of_family_type(rarities: Array[Card.Rarity], family_type: Family.FamilyType, cards: Array[Card]) -> Array[Card]:
	var cards_matching_rarities: Array[Card]
	for rarity in rarities:
		cards_matching_rarities.append_array(_get_all_cards_of_rarity(rarity, family_type, cards))
	return cards_matching_rarities



















 
