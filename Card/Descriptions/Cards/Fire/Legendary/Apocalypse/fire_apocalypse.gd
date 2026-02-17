class_name FireApocalypse
extends HeroUpgrade

@export var _damage_ratio: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("FireApocalypse: Wrong card_lvl: ", card_lvl)
		return

	var ratio: float = _damage_ratio[card_lvl - 1]

	ctx.hero.families_stats.fire.meteor_modifiers.append(func(cb_vars: Dictionary) -> void:
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for entity: Entity in entities_inside:
			if entity == null or not is_instance_valid(entity) or entity.is_dead: continue
			if entity.team == ctx.hero.team: continue
			var ignite_stacks: float = entity.conditions.ignite_stacks
			if ignite_stacks > 0:
				var bonus_damage: float = ignite_stacks * ratio
				ctx.hero.direct_damage(entity, bonus_damage, Utils.DamageType.MAGICAL, &"Apocalypse")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"

	var ratio = str(_damage_ratio[cardlvl - 1])

	return "Meteors deal bonus magic damage equal to +" + ratio + " * target's current Ignite stacks."
