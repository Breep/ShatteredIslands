class_name ColossusEvasiveGrowth
extends CardEffect

## Colossus — augmente l'esquive physique. Chaque esquive octroie des PV max
## mais réduit l'esquive suivante (rendements décroissants).

@export var _increase_dodge: Array[float]
@export var _hp_per_dodge: Array[float]
@export var _dodge_reductions: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var dodge_mod := StatModifier.new()
	dodge_mod.id = card_name
	dodge_mod.stat_type = EntityStats.StatType.DODGE
	dodge_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	dodge_mod.calc_type = StatModifier.CalcType.ADD
	dodge_mod.value = _increase_dodge[card_lvl - 1]
	dodge_mod.tags = [Modifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(dodge_mod)

	var base_dodge: float = _increase_dodge[card_lvl - 1]
	var hp_per_dodge: float = _hp_per_dodge[card_lvl - 1]
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

		var hp_mod := StatModifier.new()
		hp_mod.id = card_name
		hp_mod.stat_type = EntityStats.StatType.HEALTH_MAX
		hp_mod.calc_type = StatModifier.CalcType.ADD
		hp_mod.value = hp_per_dodge * state[&"iteration"]
		hp_mod.tags = [Modifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(hp_mod)

		state[&"iteration"] += 1
	owner.action_modifiers_registry.register_modifier(action_mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.DODGE, card_name)
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.HEALTH_MAX, card_name)
	var action_mod := ActionModifier.new()
	action_mod.id = card_name
	action_mod.action_type = Utils.ActionCategory.DODGE
	owner.action_modifiers_registry.unregister_modifier(action_mod)


func get_description(card_lvl: int) -> String:
	return "+" + _value(_increase_dodge[card_lvl - 1]) + " [[DODGE]]\n" \
		+ "Dodge : +" + _value(_hp_per_dodge[card_lvl - 1]) + " PV max, -" \
		+ _value(_dodge_reductions[card_lvl - 1]) + " [[DODGE]]"
