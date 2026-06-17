class_name EngineerShieldRush
extends CardEffect

## Engineer — au début du combat, génère un burst de shield réparti entre tous
## les alliés.

@export var _shield_amount: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var amount: int = int(_shield_amount[card_lvl - 1])

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		if not is_instance_valid(owner): return
		var allies: Array[Entity] = owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
		if allies.is_empty(): return
		var shield_distribution: Array[float] = Utils.get_randf_distribution(amount, allies.size(), owner.battle_id)
		for i in allies.size():
			owner.alterations.inflict_condition_stacks(allies[i], shield_distribution[i], Alteration.Type.SHIELD, card_name)
			ShieldVfxSpawner.spawn_on(allies[i])
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Début de combat : " + _value(_shield_amount[card_lvl - 1]) \
		+ " [[SHIELD]] répartis sur l'équipe."
