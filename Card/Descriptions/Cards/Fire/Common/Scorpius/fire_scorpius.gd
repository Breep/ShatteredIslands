class_name FireScorpius
extends HeroUpgrade

@export var _poison_stacks: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorpius: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = int(_poison_stacks[card_lvl - 1])

	ctx.hero.families_stats.fire.meteor_modifiers.append(func(cb_vars: Dictionary) -> void:
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for entity: Entity in entities_inside:
			if entity != null and is_instance_valid(entity) and entity.team != ctx.hero.team:
				ctx.hero.inflict_condition_stacks(entity, stacks, Utils.StackType.POISON, &"Scorpius")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorpius: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every [[METEOR]] apply " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]]"
