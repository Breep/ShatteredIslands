class_name StormDynamo
extends HeroUpgrade

@export var _base_regen: Array[float]
@export var _base_shield: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Dynamo: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.dynamo_activated = true
	stats.storm.dynamo_regen = _base_regen[cardlvl - 1]
	stats.storm.dynamo_shield = _base_shield[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Dynamo: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Each Lightning cast apply " + str(_base_regen[cardlvl - 1]) + " regen and " + str(_base_shield[cardlvl - 1]) + " shield."
