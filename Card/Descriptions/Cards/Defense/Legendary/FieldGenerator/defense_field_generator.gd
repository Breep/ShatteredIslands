class_name DefenseFieldGenerator
extends HeroUpgrade

@export var _summon_interval: Array[float]
@export var _shield_amount: Array[int]
@export var _shield_interval: Array[float]
@export var _target_count: Array[int]
@export var _max_health: Array[int]
@export var _initial_shield: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("DefenseFieldGenerator: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.defense_field_generator_activated = true
	stats.defense.defense_field_generator_summon_interval = _summon_interval[cardlvl - 1]
	stats.defense.defense_field_generator_shield_amount = float(_shield_amount[cardlvl - 1])
	stats.defense.defense_field_generator_shield_interval = _shield_interval[cardlvl - 1]
	stats.defense.defense_field_generator_target_count = _target_count[cardlvl - 1]
	stats.defense.defense_field_generator_max_health = _max_health[cardlvl - 1]
	stats.defense.defense_field_generator_initial_shield = _initial_shield[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"
	
	var summon_int = str(_summon_interval[cardlvl - 1]).pad_decimals(0)
	var shield_amt = str(_shield_amount[cardlvl - 1])
	var shield_int = str(_shield_interval[cardlvl - 1]).pad_decimals(0)
	var targets = str(_target_count[cardlvl - 1])
	var hp = str(_max_health[cardlvl - 1])
	var init_shield = str(_initial_shield[cardlvl - 1])
	
	return "At the start and every " + summon_int + " sec summon a Field Generator that shields " + targets + " closest allies for " + shield_amt + " every " + shield_int + " sec. Field shield have " + hp + " HP and " + init_shield + " shield."
