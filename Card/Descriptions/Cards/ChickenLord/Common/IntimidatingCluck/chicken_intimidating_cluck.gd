class_name ChickenIntimidatingCluck
extends HeroUpgrade

@export var _stun_durations: Array[float]
@export var _stun_chances: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var stun_duration: float = _stun_durations[card_lvl - 1]
	var stun_chance: float = _stun_chances[card_lvl - 1]
	
	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
		var mod := AutoAttackModifier.new()
		mod.id = "Intimidating Cluck"
		mod.is_one_time_effect = false
		mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
			if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
			var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
			if target == null or target.is_queued_for_deletion(): return
			if Utils.is_randomize_modifier_active(stun_chance, ctx.hero.battle_id):
				chicken.inflict_status(target,Status.Type.STUN, stun_duration, &"Intimidating Cluck")
		
		chicken.auto_attack_modifier_registry.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Intimidating Cluck: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_stun_chances[cardlvl -1]).pad_decimals(0)
	var s: String = str(_stun_durations[cardlvl - 1]).pad_decimals(0)
	return "Chickens have " + c + "% chance to stun target at each auto attack for " + s + " seconds"
