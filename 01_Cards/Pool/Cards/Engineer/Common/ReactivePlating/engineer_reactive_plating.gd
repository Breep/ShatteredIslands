class_name EngineerReactivePlating
extends CardEffect

## Engineer / Colossus — le héros et ses bâtiments gagnent des stacks de Thorn
## (base + % de leurs propres PV max).
## Bâtiments : via `building_modifiers_registry` (appliqué à chaque building à son
## spawn, late-spawns inclus, avec son propre health_max). Héros : direct au début
## du combat.

@export var _base_thorn: Array[float]
@export var _hp_max_percent: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var base: float = _base_thorn[card_lvl - 1]
	var pct: float = _hp_max_percent[card_lvl - 1]

	# Bâtiments : grant propagé à chaque building au spawn.
	owner.building_modifiers_registry.register_alteration_grant(card_name, Alteration.Type.THORN, base, pct)

	# Héros : application directe au début du combat.
	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		if not is_instance_valid(owner) or owner.alterations == null: return
		owner.alterations.add_stack(Alteration.Type.THORN, base + owner.stats.health_max * pct / 100.0)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.building_modifiers_registry.unregister_alteration_grant(card_name)
	owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Le héros et ses bâtiments gagnent " + str(_base_thorn[card_lvl - 1]) + " + " \
		+ str(_hp_max_percent[card_lvl - 1]) + "% de leurs PV max en [[THORN]]."
