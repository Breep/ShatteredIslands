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
	
	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		_apply_thorn(owner, base, pct, card_name)
		)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.building_modifiers_registry.unregister_alteration_grant(card_name)
	owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Le héros et ses bâtiments gagnent " + _value(_base_thorn[card_lvl - 1]) + " + " \
		+ _value(_hp_max_percent[card_lvl - 1]) + "% des PV max du héros en [[THORN]]."


func _apply_thorn(owner: Entity, base: float, pct: float, card_name: StringName) -> void:
	if not is_instance_valid(owner): return
	var thorn_value: float = base + owner.stats.health_max * pct / 100.0
	var buildings = owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES).filter(func(e: Entity) -> bool:
		return e.category == Entity.Category.BUILDING)
	
	for building: Entity in buildings:
		if is_instance_valid(building):
			building.alterations.add_stack(Alteration.Type.THORN, thorn_value, owner, card_name)
	owner.alterations.add_stack(Alteration.Type.THORN, thorn_value, owner, card_name)












 
