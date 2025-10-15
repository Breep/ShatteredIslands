class_name PlayerDeck
extends Deck

var _active_cards: Array[Card]
var _cards_dictionary: Dictionary[Family.FamilyType, Array] # FamilyType:Array[Cards]

signal has_changed()

# ============================== Public function ==============================

func get_active_deck() -> Array[Card]:
	return _active_cards


func get_cards_by_type(family_type: Family.FamilyType) -> Array[Card]:
	if _cards_dictionary.has(family_type):
		var cards_array: Array[Card] # Because nested type is not supported yet, I need to do this shit
		for card: Card in _cards_dictionary[family_type]:
			cards_array.append(card)
		return cards_array
	else:
		return []


func get_max_lvl_cards() -> Array[Card]:
	var max_lvl_cards: Array[Card]
	for card in _active_cards:
		if card.rarity == Card.Rarity.COMMON and card.lvl == 5:
			max_lvl_cards.append(card)
		elif card.rarity == Card.Rarity.RARE and card.lvl == 3:
			max_lvl_cards.append(card)
		elif card.rarity == Card.Rarity.EPIC and card.lvl == 1:
			max_lvl_cards.append(card)
	return max_lvl_cards


func get_card_lvl(card_to_get_lvl: Card) -> int:
	for card in _active_cards:
		if card.name == card_to_get_lvl.name:
			return card.lvl
	return 0


func get_families_lvl_raw() -> Dictionary:
	#TODO Look for GameRules for the family level
	var families_lvl_raw: Dictionary
	for card in _active_cards:
		for family in card.families:
			if families_lvl_raw.has(family):
				families_lvl_raw[family] += 1
			else:
				families_lvl_raw[family] = 1
	return families_lvl_raw

# ============================== Private function ==============================

func _add_or_improve_card_to_active_cards(card_to_add: Card) -> void:
	for card in _active_cards:
		if card.name == card_to_add.name:
			if card.lvl < _get_lvl_max_of_card_rarity(card.rarity):
				card.lvl += 1
			else:
				printerr("PlayerDeck: Trying to upgrade an already maximized card - ", card_to_add.name)
			return
	_active_cards.append(card_to_add)
	if _cards_dictionary.has(card_to_add.family):
		_cards_dictionary[card_to_add.family].append(card_to_add)
	else:
		_cards_dictionary[card_to_add.family] = [card_to_add]


func _get_lvl_max_of_card_rarity(card_rarity: Card.Rarity) -> int:
	match card_rarity:
		Card.Rarity.COMMON:
			return 5
		Card.Rarity.RARE:
			return 3
		Card.Rarity.EPIC:
			return 1
	return 0


func _specific_add(card_to_add: Card) -> void:
	_add_or_improve_card_to_active_cards(card_to_add)
	has_changed.emit()
