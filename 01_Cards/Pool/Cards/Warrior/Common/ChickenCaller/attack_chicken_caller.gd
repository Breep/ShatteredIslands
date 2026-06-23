class_name AttackChickenCaller
extends CardEffect

## Warrior / Seigneur Poulet — à chaque auto-attaque, une chance d'invoquer un poulet.

@export var _chance: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [Modifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if owner.summon == null: return
		if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return
		owner.summon.summon_entity(Entity.EntityType.CHICKEN, SpawnLocationConfig.create_random_arena(), {})

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Attaque : " + _value(_chance[card_lvl - 1]) + "% chance d'invoquer un [[SUMMON]] poulet"
