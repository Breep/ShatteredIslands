class_name NecroNightfall
extends CardEffect

## Nightfall — carte signature du Dark Knight. Inscrit le projectile NIGHTFALL
## dans le pool d'abilités du porteur : il devient un projectile contrôlé par le
## deck, tiré par le passif Shadow Blade (cf. SE_ShadowBlade). Le niveau de la
## carte rehausse le niveau du projectile (dégâts par-level lus côté Nightfall).
## Le comportement à l'impact (dégâts magiques + Random Weakness/Vuln) vit sur
## la classe Nightfall, pas ici.


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var level_bonus: int = card_lvl - 1

	owner.projectile.register_projectile(Projectile.Type.NIGHTFALL)

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.types = [Projectile.Type.NIGHTFALL]
	mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[LevelResolver.LEVEL] += level_bonus
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var stub := ProjectileModifier.new()
	stub.id = card_name
	owner.projectile_modifiers_registry.unregister_modifier(stub)
	owner.projectile.unregister_projectile(Projectile.Type.NIGHTFALL)


func get_description(card_lvl: int) -> String:
	return "Ajoute Nightfall (level " + str(card_lvl) + ") aux projectiles contrôlés " \
		+ "par le deck : dégâts magiques + Weakness ou Vulnerability aléatoire à l'impact."
