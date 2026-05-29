# Conteneur pur de cartes, indexé par l'id de design (Card.design_id()). Un même
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
#endregion


#region ============================== Public functions ==============================
func get_card(design_id: StringName) -> Card:
	return _cards.get(design_id)


func get_cards_raw() -> Array[Card]:
	return _cards.values()


func has(design_id: StringName) -> bool:
	return _cards.has(design_id)


func contains(card: Card) -> bool:
	return card != null and _cards.has(card.design_id())


func size() -> int:
	return _cards.size()


func get_unique_card_count() -> int:
	return _cards.size()


func get_card_lvl(card: Card) -> int:
	if card == null:
		return 0
	var existing: Card = _cards.get(card.design_id())
	return existing.lvl if existing != null else 0


func get_cards_by_type(family_type: Family.Type) -> Array[Card]:
	var cards: Array[Card] = []
	for card: Card in _cards.values():
		if family_type in card.families:
			cards.append(card)
	return cards


# Ajoute une carte. Si le design est déjà présent, monte son niveau (sans
# nouvelle entrée). Retourne true si le deck a été modifié.
func add_card(card_to_add: Card) -> bool:
	if card_to_add == null:
		Verbose.error("Deck: can't add a null card", Verbose.Category.DECK)
		return false
	
	var design_id: StringName = card_to_add.design_id()
	var existing: Card = _cards.get(design_id)
	if existing != null:
		if existing.is_max_level():
			Verbose.warn("Deck: card already maxed | " + String(design_id), Verbose.Category.DECK)
			return false
		existing.lvl += 1
		has_changed.emit()
		return true
	
	_cards[design_id] = card_to_add
	card_added.emit(card_to_add)
	has_changed.emit()
	return true


func remove_card(card_to_remove: Card) -> bool:
	if card_to_remove == null:
		Verbose.error("Deck: can't remove a null card", Verbose.Category.DECK)
		return false
	return remove_card_by_id(card_to_remove.design_id())


func remove_card_by_id(design_id: StringName) -> bool:
	var existing: Card = _cards.get(design_id)
	if existing == null:
		return false
	_cards.erase(design_id)
	card_removed.emit(existing)
	has_changed.emit()
	return true
#endregion
