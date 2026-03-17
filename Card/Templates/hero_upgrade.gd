class_name HeroUpgrade
extends Resource

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(_ctx: CardContext, _card_lvl: int) -> void:
	push_warning("[HeroUpgrade] call virtual apply()")


func get_description(_cardlvl: int) -> String:
	push_warning("[HeroUpgrade] call virtual get_description()")
	return ""
