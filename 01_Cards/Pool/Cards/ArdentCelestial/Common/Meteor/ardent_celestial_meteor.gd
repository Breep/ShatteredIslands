class_name ArdentCelestialMeteor
extends CardEffect

## Ardent Celestial — invoque périodiquement un météore sur un ennemi aléatoire.
## Le météore (projectile) porte ses propres valeurs par level (dégâts magiques
## en % des PV max + ignite) ; la carte ne fait que monter son level via un
## ProjectileModifier, comme Colossus Boulder Throw.

@export var _level_bonus: Array[int]
@export var _period: Array[float]


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var period: float = _period[card_lvl - 1]

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.types = [Projectile.Type.METEOR]
	mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[LevelResolver.LEVEL] += _level_bonus[card_lvl - 1]
	owner.projectile_modifiers_registry.register_modifier(mod)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if not is_instance_valid(target): return
		owner.projectile.projectile_attack(target, Projectile.Type.METEOR, owner, ProjectileStats.new())
	)

	owner.projectile.register_projectile(Projectile.Type.METEOR)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)
	ctx.entity_owner.projectile_modifiers_registry.unregister_modifier(card_name)
	ctx.entity_owner.projectile.unregister_projectile(Projectile.Type.METEOR)


func get_description(card_lvl: int) -> String:
	return "Appelle un Météore de niv " + str(_level_bonus[card_lvl - 1]) \
		+ " toutes les " + str(_period[card_lvl - 1]) + " sec." \
		+ " Inflige des [[MAGICAL_DAMAGE]] en % des PV max."
