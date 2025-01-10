extends CardPile
class_name PlayerDeck

func add_card(card_to_add: Card) -> void: #override
	_findSameLowerCardAndReplace(card_to_add)

func _findSameLowerCardAndReplace(newCard: Card) -> void:
	for card in _cardPile:
		if card.name == newCard.name:
			if newCard.lvl > card.lvl:
				remove_card(card)
				_cardPile.append(newCard)
			else:
				printerr("Trying to add a same card but with a lower lvl")
			return
	_cardPile.append(newCard)
