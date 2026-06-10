class_name WarriorCombatShield
extends CardEffect

## Guerrier / Engineer — à chaque auto-attaque, une chance de générer du shield
## sur un allié aléatoire (soi-même inclus).

@export var _chance: Array[float]
@export var _shield_amount: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance[card_lvl - 1]
	var shield_amount: float = _shield_amount[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [Modifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return
		if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return
		var ally: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)
		if ally == null or not is_instance_valid(ally): return
		owner.alterations.inflict_condition_stacks(ally, shield_amount, Alteration.Type.SHIELD, card_name)

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "À l'attaque, " + str(_chance[card_lvl - 1]) + "% de chance de générer " \
		+ str(_shield_amount[card_lvl - 1]) + " [[SHIELD]] sur un allié."
