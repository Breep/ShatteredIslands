class_name ColossusTaintedBlood
extends HeroUpgrade

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var percent: float = _lost_hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Tainted Blood", period, func() -> void:
		var target = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
		if target == null or not is_instance_valid(target):
			return

		var max_hp: float = ctx.hero.stats.health_max
		var current_hp: float = ctx.hero.stats.health
		var lost_hp: float = max_hp - current_hp
		if lost_hp <= 0:
			return

		var stacks: float = lost_hp * (percent / 100.0)
		if stacks <= 0:
			return

		var stack_type: Utils.StackType
		if Utils.rng.randi() % 2 == 0:
			stack_type = Utils.StackType.POISON
		else:
			stack_type = Utils.StackType.IGNITE
			stacks *= 5 # TODO Magic number spotted !

		ctx.hero.inflict_condition_stacks(target, stacks, stack_type, &"Tainted Blood")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_lost_hp_percent[cardlvl - 1]) + "% of your lost HP as Poison or Ignite stacks to your target."
