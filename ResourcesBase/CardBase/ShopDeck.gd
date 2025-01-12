extends CardPile
class_name ShopDeck

func shuffle() -> void:
	if _cardPile.is_empty(): 
		return
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	for i in _cardPile.size():
			var random_index = rng.randi_range(0, _cardPile.size() - 1)
			var temp = _cardPile[i]
			_cardPile[i] = _cardPile[random_index]
			_cardPile[random_index] = temp

func construct_shopDeck(families: Array[Family], gameRules: CardRules) -> void:
	_cardPile.clear()
	for family in families:
		for card in family.cards:
			match card.rarity:
				Card.Rarity.COMMON:
					for i in gameRules.common_number:
						add_card(card)
				Card.Rarity.RARE:
					for i in gameRules.rare_number:
						add_card(card)
				Card.Rarity.EPIC:
					for i in gameRules.epic_number:
						add_card(card)
	print(_cardPile.size())
