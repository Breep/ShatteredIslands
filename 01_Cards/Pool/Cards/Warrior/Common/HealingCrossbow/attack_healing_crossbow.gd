class_name HealingCrossbow
extends CardEffect

## Warrior — à chaque auto-attaque, une chance de soigner l'allié le plus en danger.

@export var _chance: Array[float]
@export var _heal_amount: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance[card_lvl - 1]
	var heal: float = _heal_amount[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [Modifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
		if target == null: return
		owner.heal.direct(target, heal, card_name)

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Attaque : " + str(_chance[card_lvl - 1]) + "% chance de soigner " \
		+ str(_heal_amount[card_lvl - 1]) + " PV à l'allié le plus en danger"
