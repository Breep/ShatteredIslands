class_name AttackBladeRush
extends CardEffect

@export var _damage_increase: Array[float]
@export var _duration: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Blade Rush: Wrong card_lvl: ", card_lvl)
		return

	var damage: float = _damage_increase[card_lvl - 1]
	var duration: float = _duration[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Blade Rush", func() -> void:
		# Apply AD boost at battle start
		var mod := StatModifier.new()
		mod.id = &"Blade Rush"
		mod.stat_type = EntityStats.StatType.AD
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = damage
		mod.tags = [StatModifier.TagType.CARD]
		ctx.stat_modifiers.register_modifier(mod)

		# Remove after duration
		var timer := Timer.new()
		timer.wait_time = duration
		timer.one_shot = true
		timer.timeout.connect(func() -> void:
			var remove_mod := StatModifier.new()
			remove_mod.id = &"Blade Rush"
			remove_mod.stat_type = EntityStats.StatType.AD
			ctx.stat_modifiers.unregister_modifier(remove_mod)
			timer.queue_free()
		)
		ctx.hero.add_child(timer)
		timer.start()
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Blade Rush: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "At the start of fight, increase attack damage by " + str(_damage_increase[cardlvl - 1]) + " for " + str(_duration[cardlvl - 1]) + " sec."
