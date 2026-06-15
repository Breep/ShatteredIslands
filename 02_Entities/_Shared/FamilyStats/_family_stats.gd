# Base des stats de famille. Porte un index des éléments (callbacks, modifiers...)
# ajoutés par les cartes dans ses tableaux, afin de pouvoir les retirer au revert
# d'une carte sans avoir à retrouver la référence exacte côté carte. Les managers
# ne font que LIRE ces tableaux, et l'ajout/retrait n'a lieu qu'hors combat.
class_name FamilyStats
extends Resource

# card_id -> Array[{ array: Array, item: Variant }]
var _card_additions: Dictionary[StringName, Array] = {}


# Ajoute `item` dans `target_array` en mémorisant l'association à `card_id` pour
# pouvoir le retirer plus tard via remove_card_items().
func add_card_item(card_id: StringName, target_array: Array, item: Variant) -> void:
	target_array.append(item)
	if not _card_additions.has(card_id):
		_card_additions[card_id] = []
	_card_additions[card_id].append({&"array": target_array, &"item": item})


# Retire tout ce que la carte `card_id` a ajouté via add_card_item().
func remove_card_items(card_id: StringName) -> void:
	if not _card_additions.has(card_id):
		return
	for entry: Dictionary in _card_additions[card_id]:
		var arr: Array = entry[&"array"]
		arr.erase(entry[&"item"])
	_card_additions.erase(card_id)
