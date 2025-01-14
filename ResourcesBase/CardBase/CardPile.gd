extends Resource
class_name CardPile

var _cardPile: Array[Card] = []

var cardPile: Array[Card]:
	get: return _cardPile
	set(_value): pass

func add_card(card_to_add: Card) -> void:
	if card_to_add == null:
		printerr("Can't add a null card inside the cardPile")
	else:
		_cardPile.append(card_to_add)

func remove_card(card_to_remove: Card) -> void:
	if card_to_remove == null:
		printerr("Can't remove a null card")
		return
	if card_to_remove in _cardPile:
		_cardPile.erase(card_to_remove)
		
func remove_all_same_card(card_to_remove: Card) -> void:
	_remove_all_same_card_in_array(card_to_remove, _cardPile)
	
func remove_card_at_pos(index: int) -> void:
	_remove_card_at_pos_in_array(index, _cardPile)

func draw_card(index: int) -> Card:
	return _draw_card_in_array(index, _cardPile)

func draw_random_card() -> Card:
	return _draw_random_card_in_array(_cardPile)

func draw_n_random_card(number :int) -> Array[Card]:
	return _draw_n_random_card_in_array(number, _cardPile)


func _remove_all_same_card_in_array(card_to_remove: Card, cards: Array[Card]) -> void:
	if card_to_remove == null:
		printerr("Can't remove a null card")
		return
	while card_to_remove in cards:
		cards.erase(card_to_remove)
		
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
		remove_card_at_pos(index)
		return drawn_card
	else:
		printerr("Invalid index", index)
		return null

func _draw_random_card_in_array(cards: Array[Card]) -> Card:
	if _cardPile.is_empty():
		return null
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var random_index = rng.randi_range(0, _cardPile.size() - 1)
	return draw_card(random_index)

func _draw_n_random_card_in_array(number :int, cards: Array[Card]) -> Array[Card]:
	if cards.is_empty():
		printerr("The cardPile is empty. Cannot draw cards.")
		return []
		
	if number > _get_diffent_cards_number_in_array(cards):
		printerr("Requested number of cards exceeds the available cards.")
		number = _get_diffent_cards_number_in_array(cards)
		return []
	var random_card_array: Array[Card] = []
	var cardscopy = cards.duplicate()
	while random_card_array.size() < number:
		var random_card = _draw_random_card_in_array(cardscopy)
		if random_card not in random_card_array:
			random_card_array.append(random_card)
	return random_card_array

func size():
	return _cardPile.size()
	
func get_card_lvl(card: Card) -> int:
	while card in _cardPile:
		return card.lvl
	return 0

func _remove_duplicates_in_array(cards: Array) -> Array:
	var unique_elements = []
	for element in cards:
		if element not in unique_elements:
			unique_elements.append(element)
	return unique_elements
	
func _get_diffent_cards_number_in_array(cards: Array[Card]) -> int:
	return _remove_duplicates_in_array(cards).size()
