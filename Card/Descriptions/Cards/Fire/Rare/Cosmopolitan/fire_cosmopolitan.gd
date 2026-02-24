class_name FireCosmopolitan
extends HeroUpgrade

@export var _bonus_damage_ratio: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("FireCosmopolitan: Wrong card_lvl: ", card_lvl)
		return

	var bonus_ratio: float = _bonus_damage_ratio[card_lvl - 1]

	ctx.hero.families_stats.fire.meteor_modifiers.append(func(cb_vars: Dictionary) -> void:
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		var damage_percent: float = cb_vars.get(Meteor.VarType.DAMAGE_PERCENT, 0.0)

		var targets: Array[Entity] = []
		for entity: Entity in entities_inside:
			if entity != null and is_instance_valid(entity) and not entity.is_dead() and entity.team != ctx.hero.team:
				targets.append(entity)

		if targets.size() == 1:
			var extra_damage_percent: float = damage_percent * bonus_ratio
			ctx.hero.direct_damage_percent(targets[0], extra_damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP, &"Cosmo'Politan")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"

	var ratio = str(_bonus_damage_ratio[cardlvl - 1] * 100.0).pad_decimals(0)

	return "Meteor deals " + ratio + "% more damage if it hits only 1 enemy."
