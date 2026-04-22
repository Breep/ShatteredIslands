class_name SerenityLuminescentSurge
extends HeroUpgrade

@export var _base_period: Array[float]
@export var _base_target_count: Array[int]
@export var _base_heal_percent: Array[float] # % of lost HP
@export var _base_regen_amount: Array[float]
@export var _base_hp_threshold: Array[float] # % HP threshold for regen

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Luminescent Surge: Wrong card_lvl: ", card_lvl)
		return

	var period: float = _base_period[card_lvl - 1]
	var target_count: int = _base_target_count[card_lvl - 1]
	var heal_percent: float = _base_heal_percent[card_lvl - 1]
	var regen_amount: float = _base_regen_amount[card_lvl - 1]
	var hp_threshold: float = _base_hp_threshold[card_lvl - 1]

	ctx.periodic_timers.register(&"Luminescent Surge", period, func() -> void:
		var allies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		var valid_allies: Array[Entity] = []
		for ally: Entity in allies:
			if ally != null and is_instance_valid(ally) and not ally.is_dead():
				valid_allies.append(ally)

		valid_allies.sort_custom(func(a: Entity, b: Entity) -> bool:
			return (a.stats.health / a.stats.health_max) < (b.stats.health / b.stats.health_max)
		)

		var count: int = mini(target_count, valid_allies.size())
		for i: int in range(count):
			var ally: Entity = valid_allies[i]
			var max_hp: float = ally.stats.health_max
			var current_hp: float = ally.stats.health
			var lost_hp: float = max_hp - current_hp

			if lost_hp > 0:
				var heal_amount: float = lost_hp * (heal_percent / 100.0)
				if heal_amount > 0:
					ctx.hero.heal(ally, heal_amount, &"Luminescent Surge")

			if max_hp > 0:
				var hp_percent: float = (current_hp / max_hp) * 100.0
				if hp_percent < hp_threshold and regen_amount > 0:
					ctx.hero.inflict_condition_stacks(ally, regen_amount, Alteration.Type.REGEN, &"Luminescent Surge")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Luminescent Surge: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var period = str(_base_period[cardlvl - 1]).pad_decimals(1)
	var targets = str(_base_target_count[cardlvl - 1])
	var heal_pct = str(_base_heal_percent[cardlvl - 1]).pad_decimals(0)
	var regen = str(_base_regen_amount[cardlvl - 1]).pad_decimals(0)
	var thresh = str(_base_hp_threshold[cardlvl - 1]).pad_decimals(0)

	return "Every " + period + " sec, Heal up to " + targets + " allies for " + heal_pct + "% lost HP. Apply " + regen + " regen if target below " + thresh + "% HP"
