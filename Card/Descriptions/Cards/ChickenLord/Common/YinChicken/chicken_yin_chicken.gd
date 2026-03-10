class_name ChickenYinChicken
extends HeroUpgrade

@export var _vulnerable_applications: Array[float]
@export var _chances: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var vulnerable_application: float = _vulnerable_applications[card_lvl - 1]
	var chance: float = _chances[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.on_chicken_death_callbacks.append(func(cb_vars: Dictionary) -> void:
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
			if not is_instance_valid(chicken): return
			for ennemy in ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES):
				for action_type: Utils.ActionType in Utils.get_all_actions():
					var mod := StatModifier.new()
					mod.calc_type = StatModifier.CalcType.ADD
					mod.id = "ChickenYin_" + str(chicken.uid)
					mod.stat_type = EntityStats.StatType.VULNERABILITY
					mod.action_type = action_type
					mod.value = vulnerable_application
					ennemy.stat_modifiers_registry.register_modifier(mod)
		)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rapid Incubation: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_chances[cardlvl - 1]).pad_decimals(0)
	var s: String = str(_vulnerable_applications[cardlvl - 1]).pad_decimals(0)
	return "When a friendly chicken is spawned, " + c + "% chance to apply weakness to ennemies by " + s + "."
