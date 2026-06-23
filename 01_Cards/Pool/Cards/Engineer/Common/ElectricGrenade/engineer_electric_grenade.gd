class_name EngineerElectricGrenade
extends CardEffect

## Engineer — lance périodiquement une grenade électrique (trajectoire en cloche)
## sur l'ennemi le plus éloigné. Le comportement AoE et les valeurs par-level vivent
## sur la classe Grenade (cf. grenade.gd : _damage, _vulnerability_stacks,
## _hit_radius par level). La carte n'a qu'à :
##   1) enregistrer GRENADE dans le pool d'abilités du porteur (cf. CLAUDE.md §7)
##   2) registrer un ProjectileModifier qui boost le level des grenades de
##      (card_lvl - 1)
##   3) déclencher le spawn périodique avec attribution (source_id = card_name)

@export var _period: Array[float]


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var period: float = _period[card_lvl - 1]
	var level_bonus: int = card_lvl - 1
	
	owner.projectile.register_projectile(Projectile.Type.GRENADE)
	
	var mod := ProjectileModifier.new()
	mod.id = card_name
	mod.types = [Projectile.Type.GRENADE]
	mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
		cb_vars[LevelResolver.LEVEL] += level_bonus
	owner.projectile_modifiers_registry.register_modifier(mod)
	
	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.FARTHEST_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		var proj_stats := ProjectileStats.new()
		proj_stats.source_id = card_name
		owner.projectile.projectile_attack(target, Projectile.Type.GRENADE, owner, proj_stats)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.battle_callback_registry.unregister_all(card_name)
	owner.projectile_modifiers_registry.unregister_modifier(card_name)
	owner.projectile.unregister_projectile(Projectile.Type.GRENADE)


func get_description(card_lvl: int) -> String:
	return "[[SMALL_PROJECTILE]][[ICON:COOLDOWN]] " + _value(_period[card_lvl - 1]) + " s\n" \
		+ "Grenade niv " + _value(card_lvl) + " : explose en zone, [[MAGICAL_DAMAGE]] + [[VULNERABILITY]]"
