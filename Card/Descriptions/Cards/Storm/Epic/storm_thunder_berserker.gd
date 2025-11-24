class_name StormThunderBerserker
extends CharacterUpgrade

@export var _start_boost: Array[float]
@export var _delay: Array[float]
@export var _penalty_per_rank: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Berserker: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.thunder_berserker_activated = true
	stats.storm.thunder_berserker_start_boost = _start_boost[cardlvl - 1]
	stats.storm.thunder_berserker_delay = _delay[cardlvl - 1]
	stats.storm.thunder_berserker_penalty_per_rank = _penalty_per_rank[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Berserker: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "When battle start, increase [[CRIT_MULTIPLIER]] by " + str(_start_boost[cardlvl - 1]) + "%. After " + str(_delay[cardlvl - 1]) + "s, your [[CRIT_MULTIPLIER]] decreases by " + str(_penalty_per_rank[cardlvl - 1]) + "% after each [[RANK]] grind."
