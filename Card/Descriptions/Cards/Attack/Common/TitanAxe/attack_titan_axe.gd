class_name AttackTitanAxe
extends HeroUpgrade

@export var _attack_number: int # Attack number needed to proc the damage buff
@export var _damage_percent: Array[float] # Damage buff in % of target hp max


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var dmg_pct: float = _damage_percent[card_lvl - 1]
	var atk_threshold: int = _attack_number
	var state := {&"count": 0}

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Titan Axe"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_attack_logic_callback = func(_cb_vars: Dictionary) -> void:
		state[&"count"] += 1
	aa_mod.on_hit_logic_callback = func(cb_vars: Dictionary) -> void:
		if state[&"count"] >= atk_threshold:
			state[&"count"] = 0
			var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
			if target and is_instance_valid(target):
				var bonus: float = target.stats.health_max * (dmg_pct / 100.0)
				ctx.hero.direct_damage(target, bonus, Utils.DamageType.PHYSICAL, &"Titan Axe")

	ctx.battle_callbacks.register_battle_start(&"Titan Axe", func() -> void:
		state[&"count"] = 0
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Titan Axe", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Titan Axe")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"

	var pct = str(_damage_percent[cardlvl - 1]).pad_decimals(1)

	return "Every " + str(_attack_number) + " attacks, increase damage by " + pct + "% of target max HP."
