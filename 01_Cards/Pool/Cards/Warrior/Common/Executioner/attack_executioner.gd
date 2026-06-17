class_name AttackExecutioner
extends CardEffect

## Warrior — les auto-attaques infligent un bonus de dégâts aux cibles à faible
## pourcentage de PV.

@export var _bonus_percent: Array[float]
@export var _hp_threshold: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var bonus: float = _bonus_percent[card_lvl - 1]
	var threshold: float = _hp_threshold[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target) or target.stats.health_max <= 0: return
		if target.stats.health / target.stats.health_max * 100.0 <= threshold:
			cb_vars[AutoAttackModifier.VarType.DAMAGE_MUL] += bonus

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Auto-attaque : +" + _value(_bonus_percent[card_lvl - 1]) \
		+ "% de dégâts sous " + _value(_hp_threshold[card_lvl - 1]) + "% [[HP]] de la cible."
