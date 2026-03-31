class_name ColossusColossalTitan
extends HeroUpgrade

@export var _periods: Array[float]
@export var _damage_factors: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Colossal Titan: Wrong card_lvl: ", card_lvl)
		return
		
	var period: float = _periods[card_lvl - 1]
	
	ctx.periodic_timers.register(&"Titan's Protection", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
			
		var ennemy: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		if ennemy == null or not is_instance_valid(ennemy):
			return
			
		var damage_factor: float = _damage_factors[card_lvl - 1]
		var damage: float = (ctx.hero.stats.scale - 1) * 100 * damage_factor
		ctx.hero.direct_damage(ennemy, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Colossal Titan")
	)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Colossal Titan: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_periods[cardlvl - 1]) + "s, a random ennemy takes " + str(_damage_factors[cardlvl - 1]) + " * bonus [[SCALE]] of the hero."
