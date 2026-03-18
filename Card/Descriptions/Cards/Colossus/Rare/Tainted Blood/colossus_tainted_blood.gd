class_name ColossusTaintedBlood
extends HeroUpgrade

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong card_lvl: ", card_lvl)
		return
	
	var percent: float = _lost_hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Tainted Blood", period, func() -> void:
		var target = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
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

		var stack_type: Stack.Type
		if Utils.get_randi_range(1, 2, ctx.hero.battle_id) % 2 == 0:
			stack_type = Stack.Type.POISON
		else:
			stack_type = Stack.Type.IGNITE
			stacks *= 3 # TODO Magic number spotted !

		ctx.hero.inflict_condition_stacks(target, stacks, stack_type, &"Tainted Blood")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_lost_hp_percent[cardlvl - 1]) + "% of your lost HP as Poison or Ignite stacks to your target."
