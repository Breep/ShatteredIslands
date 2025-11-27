class_name PlayerDeck
extends Deck

var _player_owner: Player

var _active_cards: Array[Card]
var _cards_dictionary: Dictionary[Family.FamilyType, Array] # FamilyType:Array[Cards]

signal has_changed()

# ============================== Node base functions ==============================

func _init(player_owner: Player) -> void:
	_player_owner = player_owner

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
		if card.is_max_level():
			max_lvl_cards.append(card)
	return max_lvl_cards


func get_card_lvl(card_to_get_lvl: Card) -> int:
	for card in _active_cards:
		if card.name == card_to_get_lvl.name:
			return card.lvl
	return 0


func get_family_points(family_type: Family.FamilyType) -> int:
	var family_points: int = 0
	for card: Card in _cards_dictionary.get(family_type, []):
		var value: int = Card.RARITY_CARD_VALUE[card.rarity]
		family_points += value * card.lvl
	return family_points

# ============================== Private function ==============================

func _add_or_improve_card_to_active_cards(card_to_add: Card) -> void:
	for card in _active_cards:
		if card.name == card_to_add.name:
			if not card.is_max_level():
				card.lvl += 1
				GlobalLogger.debug("'" + _player_owner.name + "' Upgrading card | " + card_to_add.name + " | " + str(card.lvl), GlobalLogger.Category.DECK)
			else:
				GlobalLogger.error("'" + _player_owner.name + "' Trying to upgrade an already maximized card | " + card_to_add.name, GlobalLogger.Category.DECK)
			return
	GlobalLogger.debug("'" + _player_owner.name + "' Adding new card | " + card_to_add.name + " | " + str(card_to_add.lvl), GlobalLogger.Category.DECK)
	_active_cards.append(card_to_add)
	if _cards_dictionary.has(card_to_add.family):
		_cards_dictionary[card_to_add.family].append(card_to_add)
	else:
		_cards_dictionary[card_to_add.family] = [card_to_add]


func _specific_add(card_to_add: Card) -> void:
	_add_or_improve_card_to_active_cards(card_to_add)
	has_changed.emit()
