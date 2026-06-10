class_name ColossusBoulderThrow
extends CardEffect

## Colossus — lance périodiquement un rocher sur un ennemi aléatoire, l'étourdit
## et lui inflige des dégâts physiques à l'impact.

@export var _level_bonus: Array[int]
@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var period: float = _period[card_lvl - 1]
	
	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.types = [Projectile.Type.BOULDER]
	mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[LevelResolver.LEVEL] += _level_bonus[card_lvl - 1]
	owner.projectile_modifiers_registry.register_modifier(mod)
	
	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if not is_instance_valid(target): return
		owner.projectile.projectile_attack(target, Projectile.Type.BOULDER, owner, ProjectileStats.new())
	)
	
	owner.projectile.register_projectile(Projectile.Type.BOULDER)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(card_name)
	ctx.entity_owner.projectile.unregister_projectile(Projectile.Type.BOULDER)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, lance un rocher sur un ennemi."
