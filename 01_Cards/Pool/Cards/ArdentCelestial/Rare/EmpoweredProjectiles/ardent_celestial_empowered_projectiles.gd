class_name ArdentCelestialEmpoweredProjectiles
extends CardEffect

## Ardent Celestial — augmente le niveau des projectiles d'abilité du héros.
## Le niveau choisit l'index lu dans les Array du projectile (dégâts, rayon…).

@export var _level_bonus: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var bonus: int = _level_bonus[card_lvl - 1]
	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.categories = [Projectile.Category.ABILITY_PROJECTILE]
	mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[LevelResolver.LEVEL] += bonus
	owner.projectile_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(card_name)


func get_description(card_lvl: int) -> String:
	return "Augmente le niveau des [[ABILITY_PROJECTILE]] de +" + _value(_level_bonus[card_lvl - 1]) + "."
