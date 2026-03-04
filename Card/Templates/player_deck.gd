class_name PlayerDeck
extends Deck

var _player_owner: Player
var _owner_name: String

@export var _active_cards: Array[Card]
var _cards_dictionary: Dictionary[Family.Type, Array] # Type:Array[Cards]

var _family_levels: Dictionary[Family.Type, int]
var _family_points: Dictionary[Family.Type, int]

#var _max_level_cards: Array[Card] # TODO Fill this

signal has_changed()
signal family_leveled_up(family_type: Family.Type, new_level: int)
signal card_maxed(card: Card)

# ============================== Node base functions ==============================

func init(player_owner: Player) -> PlayerDeck:
	_player_owner = player_owner
	_owner_name = player_owner.name
	return self

# ============================== Public function ==============================

func get_active_deck() -> Array[Card]:
	return _active_cards


func get_cards_by_type(family_type: Family.Type) -> Array[Card]:
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

func get_family_points(family_type: Family.Type) -> int: 
	return _family_points.get(family_type, 0)

func get_family_level(family_type: Family.Type) -> int:
	return _family_levels.get(family_type, 0)

func get_unique_card_count(family_type_or_list = null) -> int:
	# If null or UNDEF, return total unique cards (active deck size)
	if family_type_or_list == null or family_type_or_list == Family.Type.UNDEF:
		return _active_cards.size()
	
	# If Array, sum up counts for each family
	if family_type_or_list is Array:
		var total_count: int = 0
		for type in family_type_or_list:
			if _cards_dictionary.has(type):
				total_count += _cards_dictionary[type].size()
		return total_count
		
	# If Single Enum
	if _cards_dictionary.has(family_type_or_list):
		return _cards_dictionary[family_type_or_list].size()
		
	return 0

func add_card(card_to_add: Card) -> void:
	super.add_card(card_to_add)
	_add_or_improve_card_to_active_cards(card_to_add)
	
# ============================== Private function ==============================

func _add_or_improve_card_to_active_cards(card_to_add: Card) -> void:
	for card in _active_cards:
		if card.name == card_to_add.name:
			if not card.is_max_level():
				_update_family_points_and_level(card_to_add)
				has_changed.emit()
				card.lvl += 1
				Verbose.debug("'" + _owner_name + "' Upgrading card | " + card_to_add.name + " | " + str(card.lvl), Verbose.Category.DECK)
				if card.is_max_level():
					card_maxed.emit(card)
				
			else:
				Verbose.error("'" + _owner_name + "' Trying to upgrade an already maximized card | " + card_to_add.name, Verbose.Category.DECK)
			return 
	Verbose.debug("'" + _owner_name + "' Adding new card | " + card_to_add.name + " | " + str(card_to_add.lvl), Verbose.Category.DECK)
	_active_cards.append(card_to_add)
	_update_family_points_and_level(card_to_add)
	has_changed.emit()
	if _cards_dictionary.has(card_to_add.families[0]):
		_cards_dictionary[card_to_add.families[0]].append(card_to_add)
	else:
		_cards_dictionary[card_to_add.families[0]] = [card_to_add]


func _update_family_points_and_level(card: Card) -> void:
	for family_type: Family.Type in card.points.keys():
		if _family_points.has(family_type):
			_family_points[family_type] += card.points[family_type]
		else:
			_family_points[family_type] = card.points[family_type]
		var old_level = _family_levels.get(family_type, 0)
		_family_levels[family_type] = GameManager.game_rules.get_family_level(_family_points[family_type])
		if old_level < _family_levels[family_type]:
			family_leveled_up.emit(family_type, _family_levels[family_type])
