class_name ArdentCelestialXenoEgg
extends HeroUpgrade

@export var _proc_chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Xeno Egg: Wrong card_lvl: ", card_lvl)
		return

	var proc_chance: float = _proc_chances[card_lvl - 1]
	
	ctx.hero.families_stats.ardent_celestial.meteor_on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
		if Utils.is_randomize_modifier_active(proc_chance, ctx.hero.battle_id):
			var position: Vector3 = cb_vars.get(Meteor.VarType.POSITION)
			ctx.hero.summon.summon_entity(Entity.EntityType.CHICKEN_EGG, SpawnLocationConfig.create_exact(position, 2), {})
			
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Xeno Egg: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Chaque [[METEOR]] a " + str(_proc_chances[cardlvl - 1]) + "% de chance de faire éclore un oeuf [[CHICKEN_LORD]]."
