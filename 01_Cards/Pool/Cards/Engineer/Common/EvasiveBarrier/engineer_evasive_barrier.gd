class_name EngineerEvasiveBarrier
extends CardEffect

## Engineer — augmente l'esquive et génère du shield à chaque esquive.

@export var _dodge_increase: Array[float]
@export var _shield_gain: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner

	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.DODGE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _dodge_increase[card_lvl - 1]
	mod.tags = [Modifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(mod)

	var shield_amount: float = _shield_gain[card_lvl - 1]
	var action_mod := ActionModifier.new()
	action_mod.id = card_name
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return
		owner.alterations.inflict_condition_stacks(owner, shield_amount, Alteration.Type.SHIELD, card_name)
	owner.action_modifiers_registry.register_modifier(action_mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.DODGE, card_name)
	var action_mod := ActionModifier.new()
	action_mod.id = card_name
	action_mod.action_type = Utils.ActionCategory.DODGE
	owner.action_modifiers_registry.unregister_modifier(action_mod)


func get_description(card_lvl: int) -> String:
	return "+" + _value(_dodge_increase[card_lvl - 1]) + " [[DODGE]]\n" \
		+ "Dodge : " + _value(_shield_gain[card_lvl - 1]) + " [[SHIELD]]"
