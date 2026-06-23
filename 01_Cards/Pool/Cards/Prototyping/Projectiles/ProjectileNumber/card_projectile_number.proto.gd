# Carte de prototypage : ajoute (+1 × card_lvl) projectiles à chaque tir
# d'abilité du héros. Valide la chaîne ProjectileModifier.count_modifier_callback
# → CountResolver consommée par ProjectileComponent.projectile_attack() en
# phase pré-spawn. Filtre sur category = ABILITY_PROJECTILE pour exclure les
# auto-attaques.
class_name CardPrototypingProjectileNumber
extends CardEffect


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var extra: int = card_lvl
	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.count_modifier_callback = func(cb_vars: Dictionary) -> void:
		if randf_range(0, 1) < 0.5:
			cb_vars[CountResolver.COUNT] += 1
	mod.on_hit_callback = func(cb_vars: Dictionary) -> void:
		var target = cb_vars.get(ProjectileModifier.VarType.TARGET)
		if not is_instance_valid(target): return
		owner.alterations.direct_stack(target, 1, Alteration.Type.POISON, "proto poison")
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	# ProjectileModifiersRegistry.unregister_modifier prend un modifier mais
	# n'utilise que son .id en interne. Stub avec le bon id.
	var stub := ProjectileModifier.new()
	stub.id = card_name
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(stub)


func get_description(card_lvl: int) -> String:
	return "Tire +%d projectile(s) d'abilité supplémentaire(s)." % card_lvl
