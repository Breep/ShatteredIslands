class_name ChickenYangChicken
extends CardEffect

@export var _strength_increases: Array[float]
@export var _chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var strength_increase: float = _strength_increases[card_lvl - 1]
	var chance: float = _chances[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.add_card_item(ctx.card_id, ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks, func(cb_vars: Dictionary) -> void:
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
			if not is_instance_valid(chicken): return
			for ally in ctx.hero.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
				if ally.alterations == null: continue
				ally.alterations.add_stack(Alteration.Type.STRENGTH, strength_increase)
		)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.chicken_lord.remove_card_items(ctx.card_id)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Yang Chicken: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_chances[cardlvl - 1]).pad_decimals(0)
	var s: String = str(_strength_increases[cardlvl - 1]).pad_decimals(0)
	return "Quand un poulet allié apparaît, " + c + "% de chance d'augmenter la force des alliés de " + s + "."
