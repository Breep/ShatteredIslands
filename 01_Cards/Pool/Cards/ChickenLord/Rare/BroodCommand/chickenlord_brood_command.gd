class_name ChickenLordBroodCommand
extends CardEffect

## Chicken Lord — augmente le niveau des summons invoqués par le héros.
## (Le bonus se cumule au niveau de base du summon à son spawn.)

@export var _level_bonus: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	ctx.entity_owner.summon_modifiers_registry.register_level_bonus(card_name, _level_bonus[card_lvl - 1])


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.summon_modifiers_registry.unregister_level_bonus(card_name)


func get_description(card_lvl: int) -> String:
	return "Les [[SUMMON]] gagnent +" + str(_level_bonus[card_lvl - 1]) + " niveau(x)."
