class_name CardEffect
extends Resource

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(_ctx: CardContext, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual apply()")


# Retire du héros tout ce que apply_card a posé (modifiers, callbacks de bataille,
# callbacks/champs de famille). Appelé quand la carte quitte la main (vente,
# retrait). Implémenté par chaque carte en miroir de apply_card.
func revert_card(_ctx: CardContext, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual revert_card()")


func get_description(_cardlvl: int) -> String:
	push_warning("[CardEffect] call virtual get_description()")
	return ""
