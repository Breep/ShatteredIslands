class_name ColossusSeismicSlam
extends HeroUpgrade

@export var _increase_sizes: Array[float]
@export var _periods: Array[float]
@export var _stun_durations: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Energy Barrier: Wrong card_lvl: ", card_lvl)
		return
	
	var period: float = _periods[card_lvl - 1]
	var size_gain: float = _increase_sizes[card_lvl - 1]
	var stun_duration: float = _stun_durations[card_lvl - 1]
	
	ctx.periodic_timers.register(&"Seismic Slam", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
		
		# Size increase
		var ratio_scaling: float = ctx.hero.scale[1] + (size_gain / 100)
		ctx.hero.scale = Vector3(ratio_scaling, ratio_scaling, ratio_scaling) 
		
		# Apply stuns
		var ennemies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
		for a: Entity in ennemies:
			if a != null and is_instance_valid(a):
				ctx.hero.inflict_status(a, Status.Type.STUN, stun_duration, &"Seismic Slam")
	)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Seismic Slam: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_periods[cardlvl - 1]) + " seconds, stun all ennnemies for " + str(_stun_durations[cardlvl - 1]) + " and increase hero size by " + str(_increase_sizes[cardlvl - 1]) + "%"
 
