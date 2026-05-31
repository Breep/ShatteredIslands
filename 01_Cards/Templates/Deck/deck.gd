# Conteneur pur de cartes, indexé par l'id de design (Card.name). Un même
# design n'occupe qu'une entrée : ré-ajouter le même design fait monter son
# niveau au lieu de créer un doublon. Aucune dépendance aux singletons — base
# partagée par la main du joueur (Hand) et le coffre d'équipe (chest de Party).
class_name Deck
extends Resource

#region ============================== Signals ==============================
signal has_changed()
signal card_added(card: Card)
signal card_removed(card: Card)
#endregion


#region ============================== Export ==============================
@export var _cards: Dictionary[StringName, Card]

@export_group("Internal")
@export var _by_name: Dictionary[StringName, Array]
@export var _by_uid: Dictionary[int, Card]
#endregion


#region ============================== Public functions ==============================
func get_card(name: StringName) -> Card:
	return _cards.get(name)


func get_cards_raw() -> Array[Card]:
	return _cards.values()


func has(name: StringName) -> bool:
	return _cards.has(name)


func contains(card: Card) -> bool:
	return card != null and _cards.has(card.name)


func size() -> int:
	return _cards.size()


func get_unique_card_count() -> int:
	return _cards.size()


func get_card_lvl(card: Card) -> int:
	if card == null:
		return 0
	var existing: Card = _cards.get(card.name)
	return existing.lvl if existing != null else 0


func get_cards_by_type(family_type: Family.Type) -> Array[Card]:
	var cards: Array[Card] = []
	for card: Card in _cards.values():
		if family_type in card.families:
			cards.append(card)
	return cards


func is_max_level_card(card: Card) -> bool:
	if not _cards.has(card.name): return false
	return _cards[card.name].is_max_level()


# Ajoute une carte. Si le design est déjà présent, monte son niveau (sans
# nouvelle entrée). Retourne true si le deck a été modifié.
func add_card(card_to_add: Card) -> bool:
	if card_to_add == null:
		Verbose.error("Deck: can't add a null card", Verbose.Category.DECK)
		return false
	
	var name: StringName = card_to_add.name
	var existing: Card = _cards.get(name)
	if existing != null:
		if existing.is_max_level():
			Verbose.warn("Deck: card already maxed | " + String(name), Verbose.Category.DECK)
			return false
		existing.lvl += 1
		_by_name[name].append(card_to_add)
		_by_uid[card_to_add.uid] = card_to_add
		has_changed.emit()
		return true
	
	_cards[name] = card_to_add
	_by_uid[card_to_add.uid] = card_to_add
	_by_name[name] = [card_to_add]
	card_added.emit(card_to_add)
	has_changed.emit()
	return true


func remove_card(card_to_remove: Card) -> Array[Card]:
	if card_to_remove == null:
		Verbose.error("Deck: can't remove a null card", Verbose.Category.DECK)
		return []
	
	var removed_cards: Array[Card] = []
	_cards.erase(card_to_remove.name)
	for card: Card in _by_name[card_to_remove.name]:
		removed_cards.append(_by_uid[card.uid])
		_by_uid.erase(card.uid)
	_by_name.erase(card_to_remove.name)
	return removed_cards
#endregion
