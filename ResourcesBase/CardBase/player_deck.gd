class_name PlayerDeck
extends Deck

# ============================== Public function ==============================

func add_card(card_to_add: Card) -> void: #override
	_find_same_lower_card_and_replace(card_to_add)


func get_max_lvl_cards() -> Array[Card]:
	var max_lvl_cards: Array[Card]
	for card in _cardPile:
		if card.rarity == Card.Rarity.COMMON and card.lvl == 5:
			max_lvl_cards.append(card)
		elif card.rarity == Card.Rarity.RARE and card.lvl == 3:
			max_lvl_cards.append(card)
		elif card.rarity == Card.Rarity.EPIC and card.lvl == 1:
			max_lvl_cards.append(card)
	return max_lvl_cards


func get_card_lvl(card_to_get_lvl: Card) -> int:
	for card in _cardPile:
		if card.name == card_to_get_lvl.name:
			return card.lvl
	return 0

# ============================== Private function ==============================

func _find_same_lower_card_and_replace(new_card: Card) -> void:
	for card in _cardPile:
		if card.name == new_card.name:
			if new_card.lvl > card.lvl:
				remove_card(card)
				_cardPile.append(new_card)
			else:
				printerr("Trying to add a same card but with a lower lvl")
			return
	_cardPile.append(new_card)
