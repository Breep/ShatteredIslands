class_name DefenseFieldGenerator
extends HeroUpgrade

@export var _summon_interval: Array[float]
@export var _shield_amount: Array[int]
@export var _shield_interval: Array[float]
@export var _target_count: Array[int]
@export var _max_health: Array[int]
@export var _initial_shield: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Field Generator: Wrong card_lvl: ", card_lvl)
		return

	var summon_interval: float = _summon_interval[card_lvl - 1]
	var shield_amt: float = float(_shield_amount[card_lvl - 1])
	var shield_int: float = _shield_interval[card_lvl - 1]
	var target_count: int = _target_count[card_lvl - 1]
	var max_health: int = _max_health[card_lvl - 1]
	var initial_shield: int = _initial_shield[card_lvl - 1]

	var _summon := func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
		var mods: Dictionary = {
			FieldGenerator.Modifier.SHIELD_AMOUNT: shield_amt,
			FieldGenerator.Modifier.SHIELD_INTERVAL: shield_int,
			FieldGenerator.Modifier.INITIAL_SHIELD: initial_shield,
			FieldGenerator.Modifier.MAX_HEALTH: max_health,
			FieldGenerator.Modifier.TARGET_COUNT: target_count,
		}
		var spawn_config := SpawnLocationConfig.create_entity_relative(ctx.hero, 2.0)
		ctx.hero.summon_entity(Entity.EntityType.FIELD_GENERATOR, spawn_config, mods)

	# Summon one at battle start
	ctx.battle_callbacks.register_battle_start(&"Field Generator", func() -> void:
		_summon.call()
	)

	# Periodic summon
	ctx.periodic_timers.register(&"Field Generator", summon_interval, _summon)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return "ERROR"

	var summon_int := str(_summon_interval[cardlvl - 1]).pad_decimals(0)
	var shield_amt := str(_shield_amount[cardlvl - 1])
	var shield_int := str(_shield_interval[cardlvl - 1]).pad_decimals(0)
	var targets := str(_target_count[cardlvl - 1])
	var hp := str(_max_health[cardlvl - 1])
	var init_shield := str(_initial_shield[cardlvl - 1])

	return "Au début et toutes les " + summon_int + "s, invoque un Générateur qui donne " + shield_amt + " [[SHIELD]] aux " + targets + " alliés proches toutes les " + shield_int + "s. " + hp + " PV et " + init_shield + " [[SHIELD]]."
