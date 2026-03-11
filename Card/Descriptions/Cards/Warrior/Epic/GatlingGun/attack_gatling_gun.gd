class_name AttackGatlingGun
extends HeroUpgrade

@export var _attack_speed_min: Array[float] # % Attack speed minimum
@export var _attack_speed_max: Array[float] # % Attack speed maximum
@export var _duration: float # Duration to go from minimum to maximum attack speed

const GATLING_TICK_PERIOD: float = 1.0

enum {
	GATLING_TICKS
}

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gatling Gun: Wrong card_lvl: ", card_lvl)
		return

	var speed_min: float = _attack_speed_min[card_lvl - 1]
	var speed_max: float = _attack_speed_max[card_lvl - 1]
	var duration: float = _duration

	var state: Dictionary = { GATLING_TICKS: 0 }

	ctx.periodic_timers.register(&"Gatling Gun", GATLING_TICK_PERIOD, func() -> void:
		state[GATLING_TICKS] += 1
		var time_elapsed: float = GATLING_TICK_PERIOD * state[GATLING_TICKS]
		Verbose.debug("Time Elapsed " + str(time_elapsed), Verbose.Category.CARD)
		var attack_speed_boost: float = remap(time_elapsed, 0, duration, speed_min, speed_max)
		var clamped_boost: float = clampf(attack_speed_boost, speed_min, speed_max)

		var mod := StatModifier.new()
		mod.id = &"Gatling Gun"
		mod.stat_type = EntityStats.StatType.AS
		mod.calc_type = StatModifier.CalcType.MULT
		mod.value = clamped_boost / 100.0
		mod.tags = [StatModifier.TagType.CARD]
		ctx.stat_modifiers.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gatling Gun: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase auto-attack speed from " + str(_attack_speed_min[cardlvl - 1]) + " to " + str(_attack_speed_max[cardlvl - 1]) + \
			" during " + str(_duration) + "s"
