# Main du joueur : un Deck avec une limite de slots (par carte distincte). La
# main représente directement les cartes posées sur le héros ; acheter plusieurs
# fois un même design le fait monter de niveau sans consommer de slot en plus.
class_name Hand
extends Deck

signal max_slot_changed(new_max_slots: int)

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
	if is_max_level_card(card): return false
	return not is_full() or contains(card)


func add_card(card_to_add: Card) -> bool:
	if not can_add(card_to_add):
		Verbose.warn("'" + _owner_name + "' Hand full, can't add | " + card_to_add.name, Verbose.Category.DECK)
		return false
	return super.add_card(card_to_add)
#endregion
