class_name AttackDiamondSword
extends CharacterUpgrade

@export var _damage: Array[int] # damage increase
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.diamond_sword_activated = true
	stats.auto_attack.diamond_sword_attack = _damage[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increase turret damage by " + str(_damage[cardlvl - 1]) + ".[/center]"
