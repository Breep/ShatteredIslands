class_name ColossusVitalPulse
extends HeroUpgrade

@export var _period: Array[float] 
@export var _damage_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Vital Pulse: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.vital_pulse_activated = true
	stats.life.vital_pulse_period = _period[cardlvl - 1]
	stats.life.vital_pulse_damage_percent = _damage_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Vital Pulse: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + " sec, deal " + str(_damage_percent[cardlvl - 1]) + "% current HP as physical damage to all enemies."
