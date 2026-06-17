class_name EngineerShieldThrow
extends CardEffect

## Engineer — lance périodiquement un Shield Throw sur l'ennemi le plus proche.

@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var period: float = _period[card_lvl - 1]
	var level_bonus: int = card_lvl - 1

	owner.projectile.register_projectile(Projectile.Type.SHIELD_THROW)

	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.types = [Projectile.Type.SHIELD_THROW]
	mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[LevelResolver.LEVEL] += level_bonus
	owner.projectile_modifiers_registry.register_modifier(mod)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		var proj_stats := ProjectileStats.new()
		proj_stats.source_id = card_name
		owner.projectile.projectile_attack(target, Projectile.Type.SHIELD_THROW, owner, proj_stats)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.battle_callback_registry.unregister_all(card_name)
	owner.projectile_modifiers_registry.unregister_modifier(card_name)
	owner.projectile.unregister_projectile(Projectile.Type.SHIELD_THROW)


func get_description(card_lvl: int) -> String:
	return "[[SMALL_PROJECTILE]][[ICON:COOLDOWN]] " + _value(_period[card_lvl - 1]) + " s\n" \
		+ "Lance un bouclier niv " + _value(card_lvl) \
		+ " : [[MAGICAL_DAMAGE]], rebondit et régénère du [[SHIELD]]."
