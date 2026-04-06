class_name EngineerMagneticSiphon
extends HeroUpgrade

@export var _period: Array[float]
@export var _steal_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Magnetic Siphon: Wrong card_lvl: ", card_lvl)
		return
	
	var period: float = _period[card_lvl - 1]
	var percent: float = _steal_percent[card_lvl - 1]
	
	ctx.periodic_timers.register(&"Magnetic Siphon", period, func() -> void:
		if not is_instance_valid(ctx.hero): return
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO)
		if not is_instance_valid(target): return
		var highest_shield: float = target.conditions.shield_stacks
		if highest_shield <= 0: return
		var steal_amount: float = highest_shield * percent / 100.0
		if steal_amount <= 0: return
		target.conditions.remove_stack(Stack.Type.SHIELD, steal_amount)
		ctx.hero.inflict_condition_stacks(ctx.hero, steal_amount, Stack.Type.SHIELD, &"Magnetic Siphon")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Magnetic Siphon: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_period[cardlvl - 1]) + "s, vole " + str(_steal_percent[cardlvl - 1]) + "% du plus gros [[SHIELD]] ennemi."
