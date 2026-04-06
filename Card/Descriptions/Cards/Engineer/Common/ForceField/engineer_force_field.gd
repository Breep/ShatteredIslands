class_name EngineerForceField
extends HeroUpgrade

@export var _period: Array[float]
@export var _lost_hp_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Force Field: Wrong card_lvl: ", card_lvl)
		return
	
	var period: float = _period[card_lvl - 1]
	var percent: float = _lost_hp_percent[card_lvl - 1]
	
	ctx.periodic_timers.register(&"Force Field", period, func() -> void:
		if not is_instance_valid(ctx.hero): return
		var max_hp: float = ctx.hero.stats.health_max
		var current_hp: float = ctx.hero.stats.health
		var lost_hp: float = max_hp - current_hp
		if lost_hp > 0:
			var armor_gain: int = int(lost_hp * (percent / 100.0))
			if armor_gain > 0:
				ctx.hero.inflict_condition_stacks(ctx.hero, armor_gain, Stack.Type.SHIELD, &"Force Field")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Force Field: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_period[cardlvl - 1]) + "s, gagne un [[SHIELD]] égal à " + str(_lost_hp_percent[cardlvl - 1]) + "% des PV perdus."
