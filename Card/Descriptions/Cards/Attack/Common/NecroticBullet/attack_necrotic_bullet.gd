class_name AttackNecroticBullet
extends CharacterUpgrade

@export var _chance: Array[int]
@export var _necrosis_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("AttackNecroticBullet: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.necrotic_bullet_activated = true
	stats.auto_attack.necrotic_bullet_chance = float(_chance[cardlvl - 1])
	stats.auto_attack.necrotic_bullet_necrosis_stacks = float(_necrosis_stacks[cardlvl - 1])

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"
	
	var c = str(_chance[cardlvl - 1])
	var s = str(_necrosis_stacks[cardlvl - 1]).pad_decimals(0)
	
	return c + "% chance to inflict " + s + " [[NECROSIS_STACK]] on auto attack."
