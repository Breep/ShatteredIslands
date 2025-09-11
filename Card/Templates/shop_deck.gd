class_name ShopDeck
extends Deck

signal available_cards_composition_changed(new_family_composition: Dictionary[Family.FamilyType, int])
var available_cards_composition: Dictionary[Family.FamilyType, int] # Key=FamilyType, Value=number of cards of this family in the available cards

# ============================== Public function ==============================

func construct_shop_deck(families: Array[Family], game_rules: GameRules) -> void:
	_card_pile.clear()
	var uid: int = 0
	for family in families:
		for card in family.cards:
			var number_of_cards_to_add: int
			match card.rarity:
				Card.Rarity.COMMON: number_of_cards_to_add = game_rules.common_number
				Card.Rarity.RARE: number_of_cards_to_add = game_rules.rare_number
				Card.Rarity.EPIC: number_of_cards_to_add = game_rules.epic_number
			for i in number_of_cards_to_add:
				var ucard: Card = card.duplicate()
				ucard.uid = uid
				ucard.lvl = 1
				uid += 1
				add_card(ucard)
	_update_available_cards_composition(_card_pile.values(), [])


func draw_n_cards(number_of_cards_to_draw: int, player_deck: PlayerDeck = null) -> Array[Card]:
	if player_deck == null:
		return _legacy_draw_n_card(number_of_cards_to_draw)
	else:
		return _smart_draw_n_card(number_of_cards_to_draw, player_deck)


func remove_from_available_cards(card_to_remove: Card) -> void:
	_update_available_cards_composition([], [card_to_remove])

# ============================== Private function ==============================

func _update_available_cards_composition(new_cards: Array[Card], removed_cards: Array[Card]) -> void:
	for card in new_cards:
		if available_cards_composition.has(card.family):
			available_cards_composition[card.family] += 1
		else:
			available_cards_composition[card.family] = 1
	
	for card in removed_cards:
		available_cards_composition[card.family] -= 1
	
	available_cards_composition_changed.emit(available_cards_composition)
