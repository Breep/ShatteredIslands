class_name ArdentCelestialCullingBeam
extends CardEffect

## Ardent Celestial — les projectiles d'abilité du héros exécutent les ennemis
## dont les PV tombent sous un pourcentage seuil.
## NOTE: appliqué aux projectiles du héros (la carte est libellée "Aura" ; l'aura
## d'équipe ne propage pas les ProjectileModifier — voir CLAUDE.md §9).

@export var _execute_threshold: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var threshold: float = _execute_threshold[card_lvl - 1]

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.on_hit_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(owner): return
		var target: Entity = cb_vars.get(ProjectileModifier.VarType.TARGET)
		if not is_instance_valid(target) or target.stats.health_max <= 0: return
		if target.stats.health / target.stats.health_max * 100.0 <= threshold:
			owner.damage.direct(target, target.stats.health, Utils.ActionType.DAMAGE_PURE, card_name)
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var stub := ProjectileModifier.new()
	stub.id = card_name
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(stub)


func get_description(card_lvl: int) -> String:
	return "Les projectiles d'abilité exécutent les ennemis sous " \
		+ str(_execute_threshold[card_lvl - 1]) + "% de leurs PV."
