class_name ArdentCelestialFireBall
extends HeroUpgrade

@export var _damages: Array[float]
@export var _chances_to_bounce: Array[float]
@export var _periods: Array[float]
@export var _ignite_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fire Ball: Wrong card_lvl: ", card_lvl)
		return

	var damage: float = _damages[card_lvl - 1]
	var chance_to_bounce: float = _chances_to_bounce[card_lvl - 1]
	var period: float = _periods[card_lvl - 1]
	var ignite_stack: int = _ignite_stacks[card_lvl - 1]
	
	var proj_stats := ProjectileStats.new()
	proj_stats.on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
		var hit_target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
		if not is_instance_valid(hit_target): return
		ctx.hero.inflict_condition_stacks(hit_target, ignite_stack, Stack.Type.IGNITE, &"Fire Ball")
		ctx.hero.direct_damage(hit_target, damage, Utils.ActionType.DAMAGE_MAGICAL, &"Fire Ball")
		var bounce_bonus: float = (hit_target.conditions.ignite_stacks * chance_to_bounce)/100
		var projectile: Projectile = cb_vars.get(ProjectileStats.VarType.PROJECTILE)
		projectile.add_bounce(bounce_bonus)
		)
		
	ctx.periodic_timers.register("Fire Ball", period, func() -> void:
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		if target == null: return
		ctx.hero.projectile_attack(target, Projectile.Type.FIRE_BALL, ctx.hero, proj_stats)
		)
	



func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fire Ball: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Lance une boule de feu infligeant " + str(_damages[cardlvl - 1]) + " toutes les " + str(_periods[cardlvl - 1]) + "s. Le projectile a " + str(_chances_to_bounce[cardlvl - 1]) + " * stacks d'[[IGNITE]] chances de rebondir."
