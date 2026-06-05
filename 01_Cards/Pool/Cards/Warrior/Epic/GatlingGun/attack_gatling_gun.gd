class_name AttackGatlingGun
extends CardEffect

## Warrior — la vitesse d'attaque monte progressivement d'un minimum vers un
## maximum sur une durée donnée.

@export var _attack_speed_min: Array[float] # % Attack speed minimum
@export var _attack_speed_max: Array[float] # % Attack speed maximum
@export var _duration: float # Durée pour passer du minimum au maximum

const GATLING_TICK_PERIOD: float = 1.0

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var speed_min: float = _attack_speed_min[card_lvl - 1]
	var speed_max: float = _attack_speed_max[card_lvl - 1]
	var duration: float = _duration

	var state := {&"ticks": 0}

	owner.battle_callback_registry.register_periodic(card_name, GATLING_TICK_PERIOD, func() -> void:
		state[&"ticks"] += 1
		var time_elapsed: float = GATLING_TICK_PERIOD * state[&"ticks"]
		var attack_speed_boost: float = remap(time_elapsed, 0, duration, speed_min, speed_max)
		var clamped_boost: float = clampf(attack_speed_boost, speed_min, speed_max)

		var mod := StatModifier.new()
		mod.id = card_name
		mod.stat_type = EntityStats.StatType.AS
		mod.calc_type = StatModifier.CalcType.MULT
		mod.value = clamped_boost / 100.0
		mod.tags = [Modifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Augmente la vitesse d'attaque de " + str(_attack_speed_min[card_lvl - 1]) \
		+ "% jusqu'à " + str(_attack_speed_max[card_lvl - 1]) + "% sur " + str(_duration) + "s."
