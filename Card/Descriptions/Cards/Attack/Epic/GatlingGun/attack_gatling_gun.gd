class_name AttackGatlingGun
extends HeroUpgrade

@export var _attack_speed_min: Array[float] # % Attack speed minimum
@export var _attack_speed_max: Array[float] # % Attack speed maximum
@export var _duration: float # Duration to go from minimum to maximum attack speed
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

const GATLING_TICK: float = 1.0

enum {
	START_TIME
}

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gatling Gun: Wrong card_lvl: ", card_lvl)
		return

	var speed_min: float = _attack_speed_min[card_lvl - 1]
	var speed_max: float = _attack_speed_max[card_lvl - 1]
	var duration: float = _duration

	var state := {START_TIME: 0}

	ctx.battle_callbacks.register_battle_start(&"Gatling Gun", func() -> void:
		state[START_TIME] = Time.get_ticks_msec()
	)

	ctx.periodic_timers.register(&"Gatling Gun", GATLING_TICK, func() -> void:
		var time_elapsed: float = (Time.get_ticks_msec() - state[START_TIME]) / 1000.0
		var attack_speed_boost: float = remap(time_elapsed, 0, duration, speed_min, speed_max)
		var clamped_boost: float = clampf(attack_speed_boost, speed_min, speed_max)

		var mod := StatModifier.new()
		mod.id = &"Gatling Gun"
		mod.stat_type = EntityStats.StatType.AS
		mod.calc_type = StatModifier.CalcType.MULT
		mod.value = clamped_boost / 100.0
		mod.tags = [StatModifier.TagType.CARD]
		ctx.stat_modifiers.update_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gatling Gun: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase auto-attack speed from " + str(_attack_speed_min[cardlvl - 1]) + " to " + str(_attack_speed_max[cardlvl - 1]) + \
			" during " + str(_duration) + "s"
