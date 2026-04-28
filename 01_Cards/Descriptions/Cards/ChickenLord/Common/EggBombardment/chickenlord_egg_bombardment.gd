class_name ChickenLordEggBombardment
extends HeroUpgrade

@export var _spawn_chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var chance: float = _spawn_chances[card_lvl - 1]
	var mod := ActionModifier.new()
	mod.action_type = Utils.ActionCategory.STACK
	mod.id = &"Egg Bombardment"
	mod.is_one_time_effect = false
	mod.tags = [ActionModifier.TagType.CARD]
	mod.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
		var stack_type: Alteration.Type = cb_vars[ActionModifier.VarType.STACK_TYPE]
		if stack_type == Alteration.Type.SHIELD: return
		var stack_value: Alteration.Type = cb_vars.get(ActionModifier.VarType.STACK_VALUE, 0)
		var target: Entity = cb_vars.get(ActionModifier.VarType.TARGET, null)
		if not is_instance_valid(target) or target.is_queued_for_deletion(): return
		for i in stack_value:
			if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
				ctx.hero.summon.summon_entity(Entity.EntityType.CHICKEN_EGG, SpawnLocationConfig.create_entity_relative(target, 2), {})
	ctx.hero.action_modifiers_registry.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Egg Bombardment: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_spawn_chances[cardlvl - 1]).pad_decimals(0)
	return "En infligeant des stacks, " + c + "% de chance de pondre un oeuf."
