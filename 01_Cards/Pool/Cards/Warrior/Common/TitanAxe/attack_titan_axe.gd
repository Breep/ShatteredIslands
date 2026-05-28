class_name AttackTitanAxe
extends CardEffect

const AXE_VISUAL = preload("res://03_SpellsAndProjectiles/Spells/TitanAxe/Visual/titan_axe_visual.tscn")
const DEPLOY_TIME: float = 0.7

@export var _attack_number: int # Attack number needed to proc the damage buff
@export var _hp_percent: Array[float] # Damage buff in % of target hp max
@export var _scale_bonuses: Array[float] # bonus to the hp_percent depending on the sender size

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var hp_pct: float = _hp_percent[card_lvl - 1]
	var atk_threshold: int = _attack_number
	var state := {&"count": 0, &"proc_active": false}
	var scale_bonus: float = _scale_bonuses[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Titan Axe"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		state[&"count"] += 1
		if state[&"count"] >= atk_threshold:
			state[&"count"] = 0
			state[&"proc_active"] = true
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not state.get(&"proc_active", false): return
		state[&"proc_active"] = false
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target): return
		var axe_vfx := AXE_VISUAL.instantiate() as Node3D
		ctx.hero.get_tree().root.add_child(axe_vfx)
		axe_vfx.global_position = target.global_position
		ctx.battle_callbacks.register_oneshot(DEPLOY_TIME, func() -> void:
			if not is_instance_valid(target): return
			var bonus: float = target.stats.health_max * (hp_pct + (ctx.hero.stats.scale - 1) * scale_bonus / 100) / 100.0
			ctx.hero.damage.direct(target, bonus, Utils.ActionType.DAMAGE_PHYSICAL, &"Titan Axe")
		)

	ctx.battle_callbacks.register_battle_start(&"Titan Axe", func() -> void:
		state[&"count"] = 0
		state[&"proc_active"] = false
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"

	var pct = str(_hp_percent[cardlvl - 1]).pad_decimals(1)
	var scale_bonus = str(_scale_bonuses[cardlvl - 1]).pad_decimals(1)
	
	return "Toutes les " + str(_attack_number) + " attaques, inflige " + pct + " + " + scale_bonus + "*[[SCALE]]" + "% des HP max de la cible."
