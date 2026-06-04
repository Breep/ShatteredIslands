class_name EngineerElectricGrenade
extends CardEffect

## Engineer — lance périodiquement une grenade électrique sur un ennemi aléatoire :
## inflige des dégâts magiques et des stacks de vulnérabilité (aux dégâts magiques).
## NOTE: visuel placeholder (Projectile.Type.COSMIC_BOLT) en attendant un asset grenade.

@export var _damage: Array[float]
@export var _vulnerability_stacks: Array[float]
@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var damage: float = _damage[card_lvl - 1]
	var vuln: float = _vulnerability_stacks[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	var on_hit_callback := func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ProjectileStats.VarType.TARGET): return
		var target: Entity = cb_vars[ProjectileStats.VarType.TARGET]
		if target == null or not is_instance_valid(target): return
		owner.damage.direct(target, damage, Utils.ActionType.DAMAGE_MAGICAL, card_name)
		if target.alterations != null:
			target.alterations.add_typed_stack(Alteration.Type.VULNERABILITY, Utils.ActionType.DAMAGE_MAGICAL, vuln)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		var proj_stats := ProjectileStats.new()
		proj_stats.on_hit_callbacks.append(on_hit_callback)
		owner.projectile.projectile_attack(target, Projectile.Type.COSMIC_BOLT, owner, proj_stats)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, lance une grenade électrique infligeant " \
		+ str(_damage[card_lvl - 1]) + " [[MAGICAL_DAMAGE]] et " \
		+ str(_vulnerability_stacks[card_lvl - 1]) + " [[VULNERABILITY]] à un ennemi."
