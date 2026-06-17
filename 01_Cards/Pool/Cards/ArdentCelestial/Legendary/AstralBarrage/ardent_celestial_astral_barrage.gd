class_name ArdentCelestialAstralBarrage
extends CardEffect

## Ardent Celestial — le héros tire des projectiles d'abilité supplémentaires.

@export var _extra_projectiles: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var extra: int = _extra_projectiles[card_lvl - 1]
	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.count_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[CountResolver.COUNT] += extra
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(card_name)


func get_description(card_lvl: int) -> String:
	return "Tire +" + _value(_extra_projectiles[card_lvl - 1]) + " [[ABILITY_PROJECTILE]] par tir."
