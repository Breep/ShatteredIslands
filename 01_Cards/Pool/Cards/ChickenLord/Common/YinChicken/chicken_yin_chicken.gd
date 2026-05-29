class_name ChickenYinChicken
extends CardEffect

@export var _vulnerable_applications: Array[float]
@export var _chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var vulnerable_application: float = _vulnerable_applications[card_lvl - 1]
	var chance: float = _chances[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.add_card_item(ctx.card_id, ctx.hero.families_stats.chicken_lord.on_chicken_death_callbacks, func(cb_vars: Dictionary) -> void:
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
			if not is_instance_valid(chicken): return
			for ennemy in ctx.hero.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
				if ennemy.alterations == null: continue
				for action_type: Utils.ActionType in Utils.get_all_actions():
					ennemy.alterations.add_typed_stack(Alteration.Type.VULNERABILITY, action_type, vulnerable_application)
		)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.chicken_lord.remove_card_items(ctx.card_id)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Yin Chicken: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_chances[cardlvl - 1]).pad_decimals(0)
	var s: String = str(_vulnerable_applications[cardlvl - 1]).pad_decimals(0)
	return "Quand un poulet allié apparaît, " + c + "% de chance d'appliquer " + s + " faiblesse aux ennemis."
