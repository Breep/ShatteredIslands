class_name ColossusTitansProtection
extends HeroUpgrade

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titan's Protection: Wrong card_lvl: ", card_lvl)
		return
	
	var percent: float = _lost_hp_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Titan's Protection", period, func() -> void:
		var max_hp: float = ctx.hero.stats.health_max
		var current_hp: float = ctx.hero.stats.health
		var lost_hp: float = max_hp - current_hp
		if lost_hp <= 0:
			return
		var heal_amount: float = lost_hp * (percent / 100.0)
		if heal_amount > 0:
			ctx.hero.heal(ctx.hero, heal_amount, &"Titan's Protection")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titan's Protection: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Toutes les " + str(_period[cardlvl - 1]) + "s, soigne " + str(_lost_hp_percent[cardlvl - 1]) + "% des PV perdus."
