class_name ColossusUnbreakableWall
extends HeroUpgrade

@export var _base_hp_threshold_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Unbreakable Wall: Wrong card_lvl: ", card_lvl)
		return
	
	ctx.hero.inflict_status(ctx.hero, Status.Type.TAUNT, 1000, &"UnbreakableWall")
	var threshold: float = _base_hp_threshold_percent[card_lvl - 1]

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

		ctx.hero.inflict_status(ctx.hero, Status.Type.TAUNT, 0, &"UnbreakableWall")
		# LOL C'EST PAS COMME CA QU'IL FAUT FAIRE

		# Disconnect all allies to save performance (one-time trigger)
		var allies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for a: Entity in allies:
			if a != null and is_instance_valid(a):
				if a.stats.health_changed.is_connected(_on_health_changed):
					a.stats.health_changed.disconnect(_on_health_changed)

	ctx.battle_callbacks.register_battle_start(&"Unbreakable Wall", func() -> void:
		state[&"triggered"] = false
		var allies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally: Entity in allies:
			if ally == null or not is_instance_valid(ally): continue
			if not ally.stats.health_changed.is_connected(_on_health_changed):
				ally.stats.health_changed.connect(_on_health_changed.bind(ally))
	)
	ctx.battle_callbacks.register_battle_end(&"Unbreakable Wall", func() -> void:
		var allies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally: Entity in allies:
			if ally == null or not is_instance_valid(ally): continue
			if ally.stats.health_changed.is_connected(_on_health_changed):
				ally.stats.health_changed.disconnect(_on_health_changed)
	)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Unbreakable Wall: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "While hero's HP > " + str(_base_hp_threshold_percent[cardlvl - 1]) + "%, hero has taunt."
