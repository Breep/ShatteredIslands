class_name ChickenLordOpeningBrood
extends CardEffect

## Chicken Lord — au début du combat, invoque immédiatement des poulets.

@export var _chicken_count: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var count: int = _chicken_count[card_lvl - 1]
	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		for i in count:
			owner.summon.summon_entity(Entity.EntityType.CHICKEN, SpawnLocationConfig.create_random_arena(), {})
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Au début du combat, invoque " + str(_chicken_count[card_lvl - 1]) + " [[SUMMON]] poulet(s)."
