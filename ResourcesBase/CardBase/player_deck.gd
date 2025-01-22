class_name PlayerDeck
extends Deck

# ============================== Public function ==============================

func add_card(card_to_add: Card) -> void: #override
	_add_or_improve_card(card_to_add)


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


func debug_print() -> void:
	print("Player deck:")
	for card in _cardPile:
		print(card.name, "->lvl[", card.lvl, "]")

# ============================== Private function ==============================

func _add_or_improve_card(new_card: Card) -> void:
	for card in _cardPile:
		if card.name == new_card.name:
			#print("UPGRADING ", new_card.name)
			if new_card.lvl > card.lvl:
				card.lvl += 1
			else:
				printerr("Trying to upgrade a card but with a lower lvl")
			return

	#print("ADDING NEW CARD ", new_card.name)
	_cardPile.append(new_card.duplicate())
