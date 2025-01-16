extends CardPile
class_name PlayerDeck

# ============================== Public function ==============================

func add_card(card_to_add: Card) -> void: #override
	_findSameLowerCardAndReplace(card_to_add)

func get_max_lvl_cards() -> Array[Card]:
	var lvlmaxcards: Array[Card]
	for card in _cardPile:
		if card.rarity == Card.Rarity.COMMON and card.lvl == 5:
			lvlmaxcards.append(card)
		elif card.rarity == Card.Rarity.RARE and card.lvl == 3:
			lvlmaxcards.append(card)
		elif card.rarity == Card.Rarity.EPIC and card.lvl == 1:
			lvlmaxcards.append(card)
	return lvlmaxcards

func get_card_lvl(cardToGetLvl: Card) -> int:
	for card in _cardPile:
		if card.name == cardToGetLvl.name:
			return card.lvl
	return 0

# ============================== Private function ==============================

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
