class_name AttackFightBack
extends CardEffect

## Warrior — augmente l'esquive ; chaque esquive accumule des dégâts d'attaque (AD).

@export var _increase_dodge: Array[float]
@export var _increase_attack_damage: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var dodge_mod := StatModifier.new()
	dodge_mod.id = card_name
	dodge_mod.stat_type = EntityStats.StatType.DODGE
	dodge_mod.calc_type = StatModifier.CalcType.ADD
	dodge_mod.value = _increase_dodge[card_lvl - 1]
	dodge_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	owner.stat_modifiers_registry.register_modifier(dodge_mod)

	var ad_per_dodge: float = _increase_attack_damage[card_lvl - 1]
	var state := {&"dodge_count": 0}

	var action_mod := ActionModifier.new()
	action_mod.id = card_name
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		state[&"dodge_count"] += 1
		var ad_mod := StatModifier.new()
		ad_mod.id = card_name
		ad_mod.stat_type = EntityStats.StatType.AD
		ad_mod.calc_type = StatModifier.CalcType.ADD
		ad_mod.value = state[&"dodge_count"] * ad_per_dodge
		ad_mod.tags = [StatModifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(ad_mod)
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
		+ ". Chaque esquive augmente l'[[AD]] de " + str(_increase_attack_damage[card_lvl - 1]) + "."
