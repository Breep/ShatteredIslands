class_name EngineerEnergyBarrier
extends CardEffect

## Engineer — génère périodiquement du shield sur le porteur.

@export var _shield_amount: Array[float]
@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var amount: int = int(_shield_amount[card_lvl - 1])
	var period: float = _period[card_lvl - 1]

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		if not is_instance_valid(owner): return
		owner.alterations.inflict_condition_stacks(owner, amount, Alteration.Type.SHIELD, card_name)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + _value(_period[card_lvl - 1]) + "s : génère " \
		+ _value(_shield_amount[card_lvl - 1]) + " [[SHIELD]]."
