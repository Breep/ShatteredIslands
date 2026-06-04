class_name CardEffect
extends Resource

## Code d'une carte appliqué au héros porteur. Chaque carte concrète implémente
## apply / revert (miroir strict l'un de l'autre) et get_description. apply/revert
## reçoivent le card_name — id stable servant à register/unregister les modifiers
## et callbacks, au lieu d'un nom hardcodé — et le card_lvl pour choisir les valeurs.

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(_ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual apply()")


# Retire du héros tout ce que apply a posé (modifiers, callbacks de bataille,
# callbacks/champs de famille). Appelé quand la carte quitte la main (vente,
# retrait). Implémenté par chaque carte en miroir strict de apply.
func revert(_ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual revert()")


func get_description(_card_lvl: int) -> String:
	push_warning("[CardEffect] call virtual get_description()")
	return ""
