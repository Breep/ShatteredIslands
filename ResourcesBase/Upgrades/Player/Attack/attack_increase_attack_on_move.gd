class_name AttackIncreaseAttackOnMove
extends PlayerUpgrade

@export var movement_increase_damage_amount: Array[int]
@export var movement_increase_damage_distance: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > movement_increase_damage_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.movement_increase_damage_amount = movement_increase_damage_amount[cardlvl - 1]
	player.stats.auto_attack.movement_increase_damage_distance = movement_increase_damage_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > movement_increase_damage_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(movement_increase_damage_distance) + " meters moved, \
			increase attack damage by " + str(movement_increase_damage_amount[cardlvl - 1]) + "[/center]"
