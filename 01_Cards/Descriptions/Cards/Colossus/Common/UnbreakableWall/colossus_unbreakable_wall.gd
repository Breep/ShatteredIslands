class_name ColossusUnbreakableWall
extends HeroUpgrade

@export var _base_hp_threshold_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Unbreakable Wall: Wrong card_lvl: ", card_lvl)
		return
	
	ctx.hero.status_sender.inflict_status(ctx.hero, Alteration.Type.TAUNT, -1, &"UnbreakableWall")
	var threshold: float = _base_hp_threshold_percent[card_lvl - 1]

	var state := {&"triggered": false}

	var _on_health_changed: Callable
	_on_health_changed = func(_new_val: float) -> void:
		if state[&"triggered"]: return
		if not is_instance_valid(ctx.hero): return
		var max_hp: float = ctx.hero.stats.health_max
		if max_hp <= 0: return
		var current_percent: float = (ctx.hero.stats.health / max_hp) * 100.0
		if current_percent > threshold: return
		state[&"triggered"] = true
		ctx.hero.alterations_module.cancel_state(Alteration.Type.TAUNT)

	ctx.battle_callbacks.register_battle_start(&"Unbreakable Wall", func() -> void:
		state[&"triggered"] = false
		if not is_instance_valid(ctx.hero): return
		if not ctx.hero.stats.health_changed.is_connected(_on_health_changed):
			ctx.hero.stats.health_changed.connect(_on_health_changed)
	)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Unbreakable Wall: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Tant que le héros a plus de " + str(_base_hp_threshold_percent[cardlvl - 1]) + "% de PV, il provoque les ennemis."
