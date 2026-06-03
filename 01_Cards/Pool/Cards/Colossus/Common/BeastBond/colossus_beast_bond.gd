class_name ColossusBeastBond
extends CardEffect

## Colossus / Seigneur Poulet — augmente les résistances (armure, magique, poison)
## d'une valeur par summon allié en vie, recalculée périodiquement.
## NOTE: le déblocage « Colosse Surdoué » (Gifted Colossus) n'est pas géré ici —
## à brancher sur le système de progression/unlock.

const RESIST_STATS: Array[EntityStats.StatType] = [
	EntityStats.StatType.ARMOR,
	EntityStats.StatType.MAGIC_RESIST,
	EntityStats.StatType.POISON_RESIST,
]

@export var _resist_per_summon: Array[float]
@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var per_summon: float = _resist_per_summon[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		if not is_instance_valid(owner): return
		var resist_value: float = _count_living_summons(owner) * per_summon
		for stat_type in RESIST_STATS:
			var mod := StatModifier.new()
			mod.id = card_name
			mod.stat_type = stat_type
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = resist_value
			mod.tags = [StatModifier.TagType.CARD]
			owner.stat_modifiers_registry.register_modifier(mod)
	, true)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.battle_callback_registry.unregister_all(card_name)
	for stat_type in RESIST_STATS:
		owner.stat_modifiers_registry.remove_modifier(stat_type, card_name)


func _count_living_summons(owner: Entity) -> int:
	var count: int = 0
	for ally in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if ally != null and is_instance_valid(ally) and ally.is_summoned() and ally.summoner == owner:
			count += 1
	return count


func get_description(card_lvl: int) -> String:
	return "Augmente les résistances de " + str(_resist_per_summon[card_lvl - 1]) \
		+ " par summon allié en vie.\nDébloque : Colosse Surdoué."
