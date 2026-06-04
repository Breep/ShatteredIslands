class_name ColossusBoulderThrow
extends CardEffect

## Colossus — lance périodiquement un rocher sur un ennemi aléatoire, l'étourdit
## et lui inflige des dégâts physiques à l'impact.
## NOTE: visuel placeholder (Projectile.Type.BULLET) en attendant un asset rocher.

@export var _damage: Array[float]
@export var _stun_duration: Array[float]
@export var _period: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var damage: float = _damage[card_lvl - 1]
	var stun_duration: float = _stun_duration[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	var on_hit_callback := func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ProjectileStats.VarType.TARGET): return
		var target: Entity = cb_vars[ProjectileStats.VarType.TARGET]
		if target == null or not is_instance_valid(target): return
		owner.alterations.inflict_status(target, Alteration.Type.STUN, stun_duration, card_name)
		owner.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, card_name)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		var projectile_stats := ProjectileStats.new()
		projectile_stats.on_hit_callbacks.append(on_hit_callback)
		owner.projectile.projectile_attack(target, Projectile.Type.BULLET, owner, projectile_stats)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, lance un rocher qui [[STUN]] " \
		+ str(_stun_duration[card_lvl - 1]) + "s et inflige " + str(_damage[card_lvl - 1]) \
		+ " [[PHYSICAL_DAMAGE]] à un ennemi."
