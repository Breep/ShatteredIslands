class_name AttackRussianRoulette
extends CardEffect

## Warrior — chaque auto-attaque inflige un pourcentage aléatoire de ses dégâts
## (entre min et max).

@export var _min_percent: Array[int]
@export var _max_percent: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var min_p: int = _min_percent[card_lvl - 1]
	var max_p: int = _max_percent[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [Modifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[AutoAttackModifier.VarType.DAMAGE_MUL] = Utils.get_randf_range(min_p, max_p, owner.battle_id)

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Les auto-attaques infligent entre " + _value(_min_percent[card_lvl - 1]) + "% et " \
		+ _value(_max_percent[card_lvl - 1]) + "% de leurs dégâts (aléatoire)."
