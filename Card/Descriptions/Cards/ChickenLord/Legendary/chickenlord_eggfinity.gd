class_name ChickenLordEggfinity
extends HeroUpgrade

@export var _egg_spawn_chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var chance: float = _egg_spawn_chances[card_lvl - 1]
	
	if card_lvl == 3:
		ctx.hero.families_stats.chicken_lord.spawn_trex_on_start = true
	
	ctx.hero.families_stats.chicken_lord.on_chicken_death_callbacks.append(func(cb_vars: Dictionary) -> void:
		var dead_chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			ctx.hero.summon_entity(Entity.EntityType.CHICKEN_EGG, SpawnLocationConfig.create_entity_relative(dead_chicken, 0.5), {})
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Eggfinity: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_egg_spawn_chances[cardlvl - 1]).pad_decimals(0)
	return "On chicken death, " + c + "% chance to spawn an egg."
