# Main du joueur : un Deck avec une limite de slots (par carte distincte). La
# main représente directement les cartes posées sur le héros ; acheter plusieurs
# fois un même design le fait monter de niveau sans consommer de slot en plus.
class_name Hand
extends Deck

enum RefusalReason {
	CARD_ALREADY_MAXED_OUT,
	HAND_IS_FULL,
}

signal max_slot_changed(new_max_slots: int)
signal card_addition_refused(card: Card, reason: RefusalReason)
## Émis quand une carte est marquée comme « tenue » (drag, vente en cours…).
## La carte reste dans _cards ; seule get_visible_cards() l'exclut.
signal card_held(card: Card)
## Émis quand une carte tenue est rendue à la main (drop dans la main).
## Pour la suppression effective (vente, coffre), c'est card_removed qui fire.
signal card_released(card: Card)

#region ============================== Export ==============================
@export var _owner_name: String

## Nombre maximum de cartes distinctes en main (variable en cours de run).
@export var _max_slots: int = 8
var max_slots: int:
	get: return _max_slots
	set(value):
		if value == _max_slots: return
		_max_slots = maxi(0, value)
#endregion


#region ============================== Private vars ==============================
# Nom de la carte actuellement « tenue » (drag-and-drop en cours, ou plus tard
# action de vente/stockage en attente de confirmation). La carte reste dans
# _cards — seul get_visible_cards() la filtre, et seul un remove_card explicite
# la retire pour de bon. Transient : pas d'@export.
var _held_card_name: StringName = &""
#endregion


#region ============================== Public functions ==============================
func init(owner_name: String = "") -> Hand:
	_owner_name = owner_name
	return self


func is_full() -> bool:
	return size() >= _max_slots


# Vrai si la carte peut entrer en main :
# - slot reste libre
# - Carte déjà présente dans le deck et non niveau max (level up)
func can_add(card: Card) -> bool:
	if card == null: return false
	if is_max_level_card(card):
		card_addition_refused.emit(card, RefusalReason.CARD_ALREADY_MAXED_OUT)
		return false
	if is_full() and not contains(card):
		card_addition_refused.emit(card, RefusalReason.HAND_IS_FULL)
		return false
	return true


func add_card(card_to_add: Card) -> bool:
	if not can_add(card_to_add):
		Verbose.warn("'" + _owner_name + "' Hand full, can't add | " + card_to_add.name, Verbose.Category.DECK)
		return false
	return super.add_card(card_to_add)


# Surcharge : si la carte retirée était tenue, on nettoie le flag (cas vente
# pendant un drag). Pas de card_released émis : la carte n'est pas rendue à la
# main, elle est supprimée.
func remove_card(card_to_remove: Card) -> Array[Card]:
	if card_to_remove != null and _held_card_name == card_to_remove.name:
		_held_card_name = &""
	return super.remove_card(card_to_remove)


# Marque la carte comme « tenue » (sortie visuelle de la main, mais toujours
# présente côté données). Une seule carte peut être tenue à la fois. Émet
# card_held + has_changed. Retourne false si la carte est introuvable ou si
# une autre carte est déjà tenue.
func hold_card(card: Card) -> bool:
	if card == null: return false
	if not _cards.has(card.name): return false
	if _held_card_name != &"":
		Verbose.warn("'" + _owner_name + "' already holding a card | " + String(_held_card_name), Verbose.Category.DECK)
		return false
	_held_card_name = card.name
	card_held.emit(card)
	has_changed.emit()
	return true


# Rend la carte tenue à la main (drop). Émet card_released + has_changed.
# Pour une vraie suppression (vente/coffre), utiliser remove_card à la place.
func release_held_card() -> Card:
	if _held_card_name == &"":
		return null
	var card: Card = _cards.get(_held_card_name)
	_held_card_name = &""
	if card != null:
		card_released.emit(card)
	has_changed.emit()
	return card


func is_holding() -> bool:
	return _held_card_name != &""


func get_held_card() -> Card:
	if _held_card_name == &"":
		return null
	return _cards.get(_held_card_name)


func is_held(card_name: StringName) -> bool:
	return _held_card_name == card_name


# Liste les cartes affichées dans le fan : toutes sauf celle actuellement tenue.
func get_visible_cards() -> Array[Card]:
	var visible: Array[Card] = []
	for c: Card in _cards.values():
		if c.name != _held_card_name:
			visible.append(c)
	return visible
#endregion
