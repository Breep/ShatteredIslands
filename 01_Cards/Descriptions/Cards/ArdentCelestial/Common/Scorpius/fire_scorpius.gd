class_name FireScorpius
extends HeroUpgrade

@export var _poison_stacks: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorpius: Wrong card_lvl: ", card_lvl)
		return
	
	var poison_stack: float = _poison_stacks[card_lvl - 1]

	ctx.hero.families_stats.ardent_celestial.meteor_on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero): return
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for entity in entities_inside:
			if entity == null or not is_instance_valid(entity): return
			ctx.hero.alterations.inflict_condition_stacks(entity, poison_stack, Alteration.Type.POISON, &"Scorpius")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorpius: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Chaque [[METEOR]] applique " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]]."
