class_name ShopDeck
extends Deck

# ============================== Public function ==============================

func shuffle() -> void:
	if _cardPile.is_empty():
		printerr("Trying to shuffle an empty card pile")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in _cardPile.size():
		var random_index =  rng.randi_range(0, _cardPile.size() - 1)
		var temp = _cardPile[i]
		_cardPile[i] = _cardPile[random_index]
		_cardPile[random_index] = temp


func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	_cardPile.clear()
	for family in families:
		for card in family.cards:
			match card.rarity:
				Card.Rarity.COMMON:
					for i in game_rules.common_number:
						add_card(card.duplicate())
				Card.Rarity.RARE:
					for i in game_rules.rare_number:
						add_card(card.duplicate())
				Card.Rarity.EPIC:
					for i in game_rules.epic_number:
						add_card(card.duplicate())


func smart_draw_n_cards(cards_to_remove: Array[Card], number_of_cards_to_draw: int):
	var card_pile_copy = _cardPile.duplicate()
	for card_to_remove in cards_to_remove:
		_remove_all_same_card_in_array(card_to_remove, card_pile_copy)
	var cardsToDraw: Array[Card] = _draw_n_random_card_in_array(number_of_cards_to_draw, card_pile_copy)
	for drawcard in cardsToDraw:
		remove_card(drawcard)
	return cardsToDraw
