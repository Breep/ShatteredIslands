class_name PoisonDeathSmoke
extends CharacterUpgrade

@export var _period: Array[float]
@export var _multiplayer: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Death Smoke: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_death_smoke_activated = true
	stats.poison.poison_death_smoke_period = _period[cardlvl - 1]
	stats.poison.poison_death_smoke_multiplier = _multiplayer[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Death Smoke: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "At the start of the fight, surrond the battefield with gas. Then the gas speads slowly toward the middle. Entities inside" \
			+ " takes " + str(_multiplayer)
