class_name StormChainLightning
extends HeroUpgrade

@export var _dist_factor: Array[float]
@export var _chance_percent: Array[float] # <--- NOUVEL EXPORT
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chain Lightning: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.chain_lightning_activated = true
	stats.storm.chain_lightning_dist_factor = _dist_factor[cardlvl - 1]
	stats.storm.chain_lightning_chance_percent = _chance_percent[cardlvl - 1] # <--- ASSIGNATION


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chain Lightning: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	# Mise à jour de la description
	return "On crit, have " + str(_chance_percent[cardlvl - 1]) + "% chance to generate an electric arc spreading to furthest enemy. Deals " + str(_dist_factor[cardlvl - 1]) + " * distance % of original damage."
