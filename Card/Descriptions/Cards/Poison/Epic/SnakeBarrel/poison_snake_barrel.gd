class_name PoisonSnakeBarrel
extends CharacterUpgrade

@export var _barrel_health: Array[int]
@export var _snake_number: Array[int]
@export var _poison_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Snake Barrel: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_snake_barrel_activated = true
	stats.poison.poison_snake_barrel_health = _barrel_health[cardlvl - 1]
	stats.poison.poison_snake_barrel_snake_number = _snake_number[cardlvl - 1]
	stats.poison.poison_snake_barrel_snake_poison_stacks = _poison_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Snake Barrel: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "At the start of fight, place a barrel full of snakes on the batteflied. The barrel has " + str(_barrel_health[cardlvl -1]) \
			+ " hp. When the barrel brakes, it releases " + str(_snake_number[cardlvl - 1]) + " snakes that each inflict " \
			+ str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACKS]]"
