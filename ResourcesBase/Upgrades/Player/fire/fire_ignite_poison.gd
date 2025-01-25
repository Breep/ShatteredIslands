extends PlayerUpgrade

class_name Fire_deal_fire_damage_onpoison

@export var deal_fire_damage_onpoisonlost: Array[float]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > deal_fire_damage_onpoisonlost.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_poison_damage += deal_fire_damage_onpoisonlost[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > deal_fire_damage_onpoisonlost.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]For every 50 lost stack of [color=#006400][wave freq=2.0 amp=5.0][hint=inflict 1 Dammage over time/stack]Poison[/hint][/wave][/color], deal" + str(deal_fire_damage_onpoisonlost[cardlvl - 1]) + "% damage of their max health[/center]"
