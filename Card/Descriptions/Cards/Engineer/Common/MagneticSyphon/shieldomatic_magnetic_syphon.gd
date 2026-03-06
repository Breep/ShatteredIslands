class_name DefenseMagneticSiphon
extends HeroUpgrade

@export var _period: Array[float]
@export var _steal_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Magnetic Siphon: Wrong card_lvl: ", card_lvl)
		return

	var period: float = _period[card_lvl - 1]
	var percent: float = _steal_percent[card_lvl - 1]

	ctx.periodic_timers.register(&"Magnetic Siphon", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO)
		if target == null or not is_instance_valid(target):
			return
		var highest_shield: float = target.conditions.shield_stacks
		if highest_shield <= 0:
			return
		var steal_amount: float = highest_shield * percent / 100.0
		if steal_amount <= 0:
			return
		# TODO: use proper steal modifier when available
		target.conditions.shield_stacks -= steal_amount
		ctx.hero.inflict_condition_stacks(ctx.hero, steal_amount, Stack.Type.SHIELD, &"Magnetic Siphon")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Magnetic Siphon: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, steal " + str(_steal_percent[cardlvl - 1]) + "% of the highest enemy [[SHIELD]] and convert it into your own."
