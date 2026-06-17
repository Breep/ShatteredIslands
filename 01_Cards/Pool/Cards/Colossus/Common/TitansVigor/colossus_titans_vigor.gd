class_name ColossusTitansVigor
extends CardEffect

## Colossus — augmente les PV max et se soigne périodiquement d'un pourcentage
## des PV perdus.

@export var _max_hp_increase: Array[float]
@export var _heal_percent: Array[float]
@export var _heal_period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var hp_mod := StatModifier.new()
	hp_mod.id = card_name
	hp_mod.stat_type = EntityStats.StatType.HEALTH_MAX
	hp_mod.calc_type = StatModifier.CalcType.ADD
	hp_mod.value = _max_hp_increase[card_lvl - 1]
	hp_mod.tags = [Modifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(hp_mod)

	var percent: float = _heal_percent[card_lvl - 1]
	var period: float = _heal_period[card_lvl - 1]
	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		if not is_instance_valid(owner): return
		var lost_hp: float = owner.stats.health_max - owner.stats.health
		if lost_hp <= 0:
			return
		var heal_amount: float = lost_hp * (percent / 100.0)
		if heal_amount > 0:
			owner.heal.direct(owner, heal_amount, card_name)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.HEALTH_MAX, card_name)
	owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Augmente les PV max de " + _value(_max_hp_increase[card_lvl - 1]) \
		+ ". Toutes les " + _value(_heal_period[card_lvl - 1]) + "s, soigne " \
		+ _value(_heal_percent[card_lvl - 1]) + "% des PV perdus."
