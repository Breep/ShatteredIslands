class_name EngineerElectricGrenade
extends CardEffect

## Engineer — lance périodiquement une grenade électrique (trajectoire en cloche)
## sur un ennemi aléatoire : à l'impact, explosion électrique infligeant dégâts
## magiques et stacks de vulnérabilité (aux dégâts magiques) à tous les ennemis
## dans une petite zone autour du point d'impact.

const ELECTRIC_EXPLOSION_VFX: PackedScene = preload("res://03_SpellsAndProjectiles/Projectiles/Grenade/VFX/VFX_Explosion_Electric_B.tscn")
const EXPLOSION_LIFETIME: float = 3.0

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

	var on_hit_callback := func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ProjectileStats.VarType.TARGET): return
		var target: Entity = cb_vars[ProjectileStats.VarType.TARGET]
		if target == null or not is_instance_valid(target): return
		var impact_pos: Vector3 = cb_vars.get(ProjectileStats.VarType.POSITION, target.global_position)
		_spawn_explosion(owner, impact_pos)
		for enemy: Entity in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
			if enemy.global_position.distance_to(impact_pos) > hit_radius: continue
			owner.damage.direct(enemy, damage, Utils.ActionType.DAMAGE_MAGICAL, card_name)
			if enemy.alterations != null:
				enemy.alterations.add_typed_stack(Alteration.Type.VULNERABILITY, Utils.ActionType.DAMAGE_MAGICAL, vuln)

	owner.battle_callback_registry.register_periodic(card_name, period, func() -> void:
		var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null or not is_instance_valid(target):
			return
		var proj_stats := ProjectileStats.new()
		proj_stats.on_hit_callbacks.append(on_hit_callback)
		owner.projectile.projectile_attack(target, Projectile.Type.GRENADE, owner, proj_stats)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func _spawn_explosion(owner: Entity, pos: Vector3) -> void:
	if not is_instance_valid(owner): return
	var vfx := ELECTRIC_EXPLOSION_VFX.instantiate() as Node3D
	owner.get_tree().current_scene.add_child(vfx)
	vfx.global_position = pos
	AudioManager.play_3d("grenade_explosion", pos)
	# Les particules sont one_shot (AnimationPlayer autoplay "Init") : on libère après coup.
	owner.get_tree().create_timer(EXPLOSION_LIFETIME).timeout.connect(func() -> void:
		if is_instance_valid(vfx):
			vfx.queue_free()
	)


func get_description(card_lvl: int) -> String:
	return "Toutes les " + str(_period[card_lvl - 1]) + "s, lance une grenade électrique infligeant " \
		+ str(_damage[card_lvl - 1]) + " [[MAGICAL_DAMAGE]] et " \
		+ str(_vulnerability_stacks[card_lvl - 1]) + " [[VULNERABILITY]] aux ennemis dans une zone."
