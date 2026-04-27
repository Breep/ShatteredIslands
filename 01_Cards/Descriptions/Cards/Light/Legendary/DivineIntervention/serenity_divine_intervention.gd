class_name SerenityDivineIntervention
extends HeroUpgrade

@export var _base_hp_threshold_percent: Array[float]
@export var _base_regen_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Divine Intervention: Wrong card_lvl: ", card_lvl)
		return

	var threshold: float = _base_hp_threshold_percent[card_lvl - 1]
	var regen: float = _base_regen_amount[card_lvl - 1]
	var state := {&"triggered": false}

	var _on_health_changed: Callable
	_on_health_changed = func(_new_val: float, ally: Entity) -> void:
		if state[&"triggered"]: return
		if ally == null or not is_instance_valid(ally): return
		var max_hp: float = ally.stats.health_max
		if max_hp <= 0: return
		var current_percent: float = (ally.stats.health / max_hp) * 100.0
		if current_percent > threshold: return

		state[&"triggered"] = true

		# Full cleanse + apply regen
		ally.alterations.cleanse(ally, 9999.0, &"Divine Intervention")
		ally.alterations.inflict_condition_stacks(ally, regen, Alteration.Type.REGEN, &"Divine Intervention")

		# Disconnect all allies to save performance (one-time trigger)
		var allies: Array[Entity] = ctx.hero.target.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for a: Entity in allies:
			if a != null and is_instance_valid(a):
				if a.stats.health_changed.is_connected(_on_health_changed):
					a.stats.health_changed.disconnect(_on_health_changed)

	ctx.battle_callbacks.register_battle_start(&"Divine Intervention", func() -> void:
		state[&"triggered"] = false
		var allies: Array[Entity] = ctx.hero.target.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally: Entity in allies:
			if ally == null or not is_instance_valid(ally): continue
			if not ally.stats.health_changed.is_connected(_on_health_changed):
				ally.stats.health_changed.connect(_on_health_changed.bind(ally))
	)
	ctx.battle_callbacks.register_battle_end(&"Divine Intervention", func() -> void:
		var allies: Array[Entity] = ctx.hero.target.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally: Entity in allies:
			if ally == null or not is_instance_valid(ally): continue
			if ally.stats.health_changed.is_connected(_on_health_changed):
				ally.stats.health_changed.disconnect(_on_health_changed)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Divine Intervention: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "The first time a hero allied reach " + str(_base_hp_threshold_percent[cardlvl - 1]) + "% HP, cleanse entirely and apply " + str(_base_regen_amount[cardlvl - 1]) + " regen to him"
