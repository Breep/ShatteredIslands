class_name ColossusTaintedBlood
extends CharacterUpgrade

@export var _lost_hp_percent: Array[float] 
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.tainted_blood_activated = true
	stats.life.tainted_blood_lost_hp_percent = _lost_hp_percent[cardlvl - 1]
	stats.life.tainted_blood_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Tainted Blood: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_lost_hp_percent[cardlvl - 1]) + "% of your lost HP as Poison or Ignite stacks to your target."
