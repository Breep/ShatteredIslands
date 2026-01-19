class_name SerenityLuminescentSurge
extends HeroUpgrade

@export var _base_period: Array[float]
@export var _base_target_count: Array[int]
@export var _base_heal_percent: Array[float] # % of lost HP
@export var _base_regen_amount: Array[float]
@export var _base_hp_threshold: Array[float] # % HP threshold for regen

@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Luminescent Surge: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.luminescent_surge_activated = true
	stats.serenity.luminescent_surge_period = _base_period[cardlvl - 1]
	stats.serenity.luminescent_surge_target_count = _base_target_count[cardlvl - 1]
	stats.serenity.luminescent_surge_heal_percent = _base_heal_percent[cardlvl - 1]
	stats.serenity.luminescent_surge_regen_amount = _base_regen_amount[cardlvl - 1]
	stats.serenity.luminescent_surge_hp_threshold_percent = _base_hp_threshold[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Luminescent Surge: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var period = str(_base_period[cardlvl - 1]).pad_decimals(1)
	var targets = str(_base_target_count[cardlvl - 1])
	var heal_pct = str(_base_heal_percent[cardlvl - 1]).pad_decimals(0)
	var regen = str(_base_regen_amount[cardlvl - 1]).pad_decimals(0)
	var thresh = str(_base_hp_threshold[cardlvl - 1]).pad_decimals(0)
	
	return "Every " + period + " sec, Heal up to " + targets + " allies for " + heal_pct + "% lost HP. Apply " + regen + " regen if target below " + thresh + "% HP"
