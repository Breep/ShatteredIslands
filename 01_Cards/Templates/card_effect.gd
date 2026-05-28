class_name CardEffect
extends Resource

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(_ctx: CardContext, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual apply()")


func get_description(_cardlvl: int) -> String:
	push_warning("[CardEffect] call virtual get_description()")
	return ""
