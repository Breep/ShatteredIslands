class_name PoisonSnakeBarrel
extends CharacterUpgrade

@export var _hits_number: Array[int]
@export var _snake_number: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > EPIC_CARD_MAX_LEVEL:
		printerr("Snake Barrel: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_snake_barrel_activated = true
	stats.poison.poison_snake_barrel_hits_number = _hits_number[cardlvl - 1]
	stats.poison.poison_snake_barrel_snake_number = _snake_number[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > EPIC_CARD_MAX_LEVEL:
		printerr("Snake Barrel: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "At the start of fight, place a barrel full of snakes on the batteflied. After taking " + str(_hits_number[cardlvl -1]) \
			+ " hits, the barrel brakes, releasing " + str(_snake_number) + " snakes"
