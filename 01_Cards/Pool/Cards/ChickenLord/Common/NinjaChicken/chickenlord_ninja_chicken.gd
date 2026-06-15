class_name ChickenLordNinjaChicken
extends CardEffect

## Chicken Lord — augmente l'esquive du héros ; les summons héritent d'un
## pourcentage de l'esquive du héros (valeur capturée au début du combat puis
## propagée aux summons à leur spawn via le summon_modifiers_registry).

@export var _dodge_increase: Array[float]
@export var _inherit_percent: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var hero_mod := StatModifier.new()
	hero_mod.id = card_name
	hero_mod.stat_type = EntityStats.StatType.DODGE
	hero_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	hero_mod.calc_type = StatModifier.CalcType.ADD
	hero_mod.value = _dodge_increase[card_lvl - 1]
	hero_mod.tags = [Modifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(hero_mod)

	var pct: float = _inherit_percent[card_lvl - 1]
	var refresh := func() -> void:
		if not is_instance_valid(owner): return
		var hero_dodge: float = owner.stats.get_effective_stat(EntityStats.StatType.DODGE, Utils.ActionType.DAMAGE_PHYSICAL)
		var summon_mod := StatModifier.new()
		summon_mod.id = card_name
		summon_mod.stat_type = EntityStats.StatType.DODGE
		summon_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		summon_mod.calc_type = StatModifier.CalcType.ADD
		summon_mod.value = hero_dodge * pct / 100.0
		summon_mod.tags = [Modifier.TagType.CARD]
		owner.summon_modifiers_registry.stat_modifiers_registry.register_modifier(summon_mod)

	refresh.call()
	# Recalcule au début du combat (l'esquife finale du héros est connue à ce moment).
	owner.battle_callback_registry.register_battle_start(card_name, func() -> void: refresh.call())


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.DODGE, card_name)
	owner.summon_modifiers_registry.stat_modifiers_registry.remove_modifier(EntityStats.StatType.DODGE, card_name)
	owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Augmente le [[DODGE]] du héros de " + str(_dodge_increase[card_lvl - 1]) \
		+ ". Les summons héritent de " + str(_inherit_percent[card_lvl - 1]) + "% de l'esquive du héros."
