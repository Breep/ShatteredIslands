class_name EngineerBlueprintUpgrade
extends CardEffect

## Engineer — augmente le niveau des bâtiments déployés par le porteur. Le bonus
## s'ajoute au niveau de base du bâtiment au spawn (cf. _apply_inherited_building_modifiers).

@export var _level_bonus: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	ctx.entity_owner.building_modifiers_registry.register_level_bonus(card_name, _level_bonus[card_lvl - 1])


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.building_modifiers_registry.unregister_level_bonus(card_name)


func get_description(card_lvl: int) -> String:
	return "Les bâtiments déployés gagnent +%d niveau(x)." % _level_bonus[card_lvl - 1]
