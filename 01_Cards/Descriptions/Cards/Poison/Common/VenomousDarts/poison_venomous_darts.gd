class_name PoisonVenomousDarts
extends HeroUpgrade

@export var _period: Array[float]
@export var _multiplier: Array[float]
@export var _darts_number: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Venomous Darts: Wrong card_lvl: ", card_lvl)
		return
	
	var multiplier: float = _multiplier[card_lvl - 1]
	var darts_number: int = _darts_number[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	
	var on_hit_callback := func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ProjectileStats.VarType.TARGET): return
		var target: Entity = cb_vars[ProjectileStats.VarType.TARGET]
		if target == null or not is_instance_valid(target): return
		var damage := 5 + float(target.alterations_module.poison_stacks) * multiplier
		ctx.hero.direct_damage(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Venomous Darts")
	
	ctx.periodic_timers.register(&"Venomous Darts", period, func() -> void:
		for i in darts_number:
			var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
			if target == null: return
			var projectile_stats := ProjectileStats.new()
			projectile_stats.on_hit_callbacks.append(on_hit_callback)
			ctx.hero.projectile_attack(target, Projectile.Type.VENOMOUS_DART, ctx.hero, projectile_stats)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Venomous Darts: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + " throw " + str(_darts_number[cardlvl - 1]) + " darts at random enemies.\n" \
			+ "Deals " + str(_multiplier[cardlvl - 1]) + " * [[POISON_STACK]] on target physical damage."
