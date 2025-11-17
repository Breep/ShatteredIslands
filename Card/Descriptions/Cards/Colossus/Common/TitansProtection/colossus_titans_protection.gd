class_name ColossusTitansProtection
extends CharacterUpgrade

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float] 
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titan's Protection: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.titans_protection_activated = true
	stats.life.titans_protection_lost_hp_percent = _lost_hp_percent[cardlvl - 1]
	stats.life.titans_protection_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titan's Protection: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, heal " + str(_lost_hp_percent[cardlvl - 1]) + "% of your lost HP."
