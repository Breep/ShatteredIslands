class_name Deck
extends Resource

# TODO Check if there is a way to compare cards other than with their names
# Can't directly do card1 == card2 because cards are duplicated ressource hence difference

# ============================== Public variables ==============================

var _card_pile: Array[Card] = []
var card_pile: Array[Card]:
	get: return _card_pile

var _families_count: Dictionary[Family.FamilyType, int]
var families_count: Dictionary[Family.FamilyType, int]:
	get: return _families_count

# ============================== Private functions ==============================

func add_card(card_to_add: Card) -> void:
	if card_to_add == null:
		printerr("Can't add a null card inside the card_pile")
	else:
		_card_pile.append(card_to_add)
		if _families_count.has(card_to_add.family):
			_families_count[card_to_add.family] += 1
		else:
			_families_count[card_to_add.family] = 1


func remove_card(card_to_remove: Card) -> void:
	if card_to_remove == null:
		printerr("Can't remove a null card")
	elif card_to_remove in _card_pile:
		_card_pile.erase(card_to_remove)
		if _families_count.has(card_to_remove.family):
			_families_count[card_to_remove.family] -= 1


func size():
	return _card_pile.size()


func remove_all_same_card(card_to_remove: Card) -> void:
	_remove_all_same_card_in_array(card_to_remove, _card_pile)


func remove_card_at_pos(index: int) -> void:
	_remove_card_at_pos_in_array(index, _card_pile)


func draw_card(index: int) -> Card:
	return _draw_card_in_array(index, _card_pile)


func draw_random_card() -> Card:
	return _draw_random_card_in_array(_card_pile)


func draw_n_random_card(number :int) -> Array[Card]:
	return _draw_n_random_card_in_array(number, _card_pile)

# ============================== Private functions ==============================

func _remove_all_same_card_in_array(card_to_remove: Card, cards: Array[Card]) -> void:
	if card_to_remove == null:
		printerr("Can't remove a null card")
		return
	
	for card in _card_pile:
		if card.name == card_to_remove.name:
			cards.erase(card)


func _remove_card_at_pos_in_array(index: int, cards: Array[Card]) -> void:
	if index >= 0 and index < cards.size():
		cards.remove_at(index)
	else:
		printerr("Invalid index :", index)


func _draw_card_in_array(index: int, cards: Array[Card]) -> Card:
	if cards.is_empty():
		printerr("Trying to draw a card in an empty deck.")
		return null
	
	if index >= 0 and index < cards.size():
		var drawn_card: Card = cards[index]
		_remove_card_at_pos_in_array(index, cards)
		return drawn_card
	else:
		printerr("Invalid index", index)
		return null


func _draw_random_card_in_array(cards: Array[Card]) -> Card:
	if cards.is_empty():
		printerr("The card_pile is empty. Cannot draw a card.")
		return null
	
	var random_index = Utils.rng.randi_range(0, cards.size() - 1)
	return _draw_card_in_array(random_index, cards)


 #TODO Improve this function to accept a draw chance rule (like 50% chance common, 30% chance rare, 20% chance epic)
func _draw_n_random_card_in_array(number_of_cards_to_draw :int, cards: Array[Card]) -> Array[Card]:
	if cards.is_empty():
		printerr("The card_pile is empty. Cannot draw cards.")
		return []
	
	if number_of_cards_to_draw > _get_diffent_cards_number_in_array(cards):
		number_of_cards_to_draw = _get_diffent_cards_number_in_array(cards)
	
	var returned_cards: Array[Card] = []
	var tmp_cards_copy = cards.duplicate()
	while returned_cards.size() < number_of_cards_to_draw:
		var randomCard = _draw_random_card_in_array(tmp_cards_copy)
		_remove_all_same_card_in_array(randomCard, tmp_cards_copy)
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
























 
