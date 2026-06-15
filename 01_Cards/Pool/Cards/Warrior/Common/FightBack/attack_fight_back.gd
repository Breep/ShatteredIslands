class_name AttackFightBack
extends CardEffect

## Warrior — augmente l'esquive ; chaque esquive accumule des dégâts d'attaque (AD)
## mais réduit l'esquive suivante (rendements décroissants).

@export var _increase_dodge: Array[float]
@export var _increase_attack_damage: Array[float]
@export var _dodge_reductions: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var dodge_mod := StatModifier.new()
	dodge_mod.id = card_name
	dodge_mod.stat_type = EntityStats.StatType.DODGE
	dodge_mod.calc_type = StatModifier.CalcType.ADD
	dodge_mod.value = _increase_dodge[card_lvl - 1]
	dodge_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	owner.stat_modifiers_registry.register_modifier(dodge_mod)

	var base_dodge: float = _increase_dodge[card_lvl - 1]
	var ad_per_dodge: float = _increase_attack_damage[card_lvl - 1]
	var dodge_reduction: float = _dodge_reductions[card_lvl - 1]
	var state := {&"iteration": 1}

	var action_mod := ActionModifier.new()
	action_mod.id = card_name
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return

		var dodge_update := StatModifier.new()
		dodge_update.id = card_name
		dodge_update.stat_type = EntityStats.StatType.DODGE
		dodge_update.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		dodge_update.calc_type = StatModifier.CalcType.ADD
		dodge_update.value = base_dodge - dodge_reduction * state[&"iteration"]
		dodge_update.tags = [Modifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(dodge_update)

		var ad_mod := StatModifier.new()
		ad_mod.id = card_name
		ad_mod.stat_type = EntityStats.StatType.AD
		ad_mod.calc_type = StatModifier.CalcType.ADD
		ad_mod.value = ad_per_dodge * state[&"iteration"]
		ad_mod.tags = [Modifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(ad_mod)

		state[&"iteration"] += 1
	owner.action_modifiers_registry.register_modifier(action_mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.DODGE, card_name)
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AD, card_name)
	var action_mod := ActionModifier.new()
	action_mod.id = card_name
	action_mod.action_type = Utils.ActionCategory.DODGE
	owner.action_modifiers_registry.unregister_modifier(action_mod)


func get_description(card_lvl: int) -> String:
	return "Augmente le [[DODGE]] de " + str(_increase_dodge[card_lvl - 1]) \
		+ ". Chaque esquive augmente l'[[AD]] de " + str(_increase_attack_damage[card_lvl - 1]) \
		+ " mais réduit l'esquive de " + str(_dodge_reductions[card_lvl - 1]) + "."
