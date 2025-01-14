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

func remove_card_at_pos(index: int) -> void:
	if index >= 0 and index < _cardPile.size():
		_cardPile.remove_at(index)
	else:
		printerr("Invalid index :", index)

func draw_card(index: int) -> Card:
	if _cardPile.is_empty():
		printerr("Trying to draw a card in an empty deck.")
		return null
	if index >= 0 and index < _cardPile.size():
		var drawn_card: Card = _cardPile[index]
		remove_card_at_pos(index)
		return drawn_card
	else:
		printerr("Invalid index", index)
		return null

func draw_random_card() -> Card:
	if _cardPile.is_empty():
		return null
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var random_index = rng.randi_range(0, _cardPile.size() - 1)
	return draw_card(random_index)

func draw_n_random_card(number :int) -> Array[Card]:
	
	if _cardPile.is_empty():
		printerr("The cardPile is empty. Cannot draw cards.")
		return []
		
	if number > _cardPile.size():
		printerr("Requested number of cards exceeds the available cards.")
		number = _cardPile.size()
		
	var random_card_array: Array[Card] = []
	while random_card_array.size() < number:
		var random_card = draw_random_card()
		if random_card not in random_card_array:
			random_card_array.append(random_card)
			print("ajouté")
		else:
			add_card(random_card)
			print("remise")
	return random_card_array
	
func size():
	return _cardPile.size()
