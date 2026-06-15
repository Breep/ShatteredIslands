class_name ChickenLordReinforcements
extends CardEffect

## Chicken Lord — chaque invocation du héros a une chance d'invoquer un summon
## supplémentaire (du même type). Générique : intercepte l'action SUMMON.

@export var _chance: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance[card_lvl - 1]

	var mod := ActionModifier.new()
	mod.id = card_name
	mod.action_type = Utils.ActionCategory.SUMMON
	mod.is_one_time_effect = false
	# Mécanisme COUNT natif du summon : on augmente le nombre d'entités invoquées.
	mod.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return
		if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return
		cb_vars[ActionModifier.VarType.COUNT] = cb_vars.get(ActionModifier.VarType.COUNT, 1) + 1
	owner.action_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var mod := ActionModifier.new()
	mod.id = card_name
	mod.action_type = Utils.ActionCategory.SUMMON
	ctx.entity_owner.action_modifiers_registry.unregister_modifier(mod)


func get_description(card_lvl: int) -> String:
	return str(_chance[card_lvl - 1]) + "% de chance d'invoquer un summon supplémentaire à chaque invocation."
