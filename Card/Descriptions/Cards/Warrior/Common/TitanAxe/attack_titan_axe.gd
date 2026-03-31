class_name AttackTitanAxe
extends HeroUpgrade

@export var _attack_number: int # Attack number needed to proc the damage buff
@export var _hp_percent: Array[float] # Damage buff in % of target hp max
@export var _scale_bonuses: Array[float] # bonus to the hp_percent depending on the sender size

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var hp_pct: float = _hp_percent[card_lvl - 1]
	var atk_threshold: int = _attack_number
	var state := {&"count": 0}
	var scale_bonus: float = _scale_bonuses[card_lvl - 1]
	
	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Titan Axe"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		state[&"count"] += 1
		if state[&"count"] >= atk_threshold:
			state[&"count"] = 0
			var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
			if target and is_instance_valid(target):
				var bonus: float = target.stats.health_max * (hp_pct + (ctx.hero.stats.scale-1)*scale_bonus/100) / 100.0
				cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] += bonus
	
	ctx.battle_callbacks.register_battle_start(&"Titan Axe", func() -> void:
		state[&"count"] = 0
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"

	var pct = str(_hp_percent[cardlvl - 1]).pad_decimals(1)
	var scale_bonus = str(_scale_bonuses[cardlvl - 1]).pad_decimals(1)
	
	return "Every " + str(_attack_number) + " attacks, increase damage by " + pct + " + " + scale_bonus + "*[[SCALE]]" + "% of target max HP."
