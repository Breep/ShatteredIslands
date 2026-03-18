class_name ColossusResurrection
extends HeroUpgrade

@export var _lost_hp_percent: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Resurrection: Wrong card_lvl: ", card_lvl)
		return


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Resurrection: Wrong cardlvl: ", cardlvl)
		return "ERROR"
		
	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_lost_hp_percent[cardlvl - 1]) + "% of your lost HP as Poison or Ignite stacks to your target."
