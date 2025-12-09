class_name AttackAimAssist
extends CharacterUpgrade

@export var _bonus_ad_per_card: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aim Assist: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.attack_aim_assist_activated = true
	stats.auto_attack.attack_aim_assist_bonus_per_card = _bonus_ad_per_card[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aim Assist: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var val = str(_bonus_ad_per_card[cardlvl - 1]).pad_decimals(1)
	
	return "Increase your Attack Damage by " + val + " for each unique Attack card you possess."
