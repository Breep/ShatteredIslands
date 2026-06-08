class_name EngineerElectricGrenade
extends CardEffect

## Engineer — lance périodiquement une grenade électrique (trajectoire en cloche)
## sur un ennemi aléatoire. Le comportement AoE à l'impact (explosion + dégâts
## magiques + vulnérabilité dans un rayon) vit dans la classe Grenade ; la
## carte se contente d'injecter les valeurs par niveau via Grenade.configure()
## au spawn du projectile.

@export var _damage: Array[float]
@export var _vulnerability_stacks: Array[float]
@export var _period: Array[float]
## Rayon (unités monde) de la zone d'explosion par niveau : tous les ennemis dans
## ce rayon autour du point d'impact subissent les dégâts et la vulnérabilité.
@export var _hit_radius: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var damage: float = _damage[card_lvl - 1]
	var vuln: float = _vulnerability_stacks[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	var hit_radius: float = _hit_radius[card_lvl - 1]

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		var proj_stats := ProjectileStats.new()
		proj_stats.on_spawn_callbacks.append(func(cb_vars: Dictionary) -> void:
			var grenade := cb_vars.get("projectile") as Grenade
			if grenade != null:
				grenade.configure(damage, vuln, hit_radius, card_name)
		)
		owner.projectile.projectile_attack(target, Projectile.Type.GRENADE, owner, proj_stats)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, lance une grenade électrique infligeant " \
		+ str(_damage[card_lvl - 1]) + " [[MAGICAL_DAMAGE]] et " \
		+ str(_vulnerability_stacks[card_lvl - 1]) + " [[VULNERABILITY]] aux ennemis dans une zone."
