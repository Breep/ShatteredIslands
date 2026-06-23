class_name SE_BruleurDirectionnel
extends SkillEffect

# Passif "Brûleur directionnel": toutes les _tick_period s, applique AP x _ap_ignite_ratio
# stacks d'Ignite à tous les ennemis présents dans la hitbox des flammes (collision shape
# de l'Area3D). De base le passif ne fait QUE de l'Ignite. Le talent "Buse large" active en
# plus des dégâts magiques, dont les valeurs sont posées en meta par SE_BuseLarge.
# La tourelle pivote (toutes les _aim_period s) pour braquer son cône sur sa cible. La
# cible est "collante" : on la garde tant qu'elle est vivante et à portée (_flame_range),
# on n'en change qu'à sa mort/sortie de portée — évite le va-et-vient entre deux ennemis
# équidistants. Le VFX de flammes est masqué quand aucune cible n'est atteignable.

const META_BUSE_FLAT := &"firethrower_buse_flat"
const META_BUSE_AP_RATIO := &"firethrower_buse_ap_ratio"

@export var _tick_period: float = 1.0
@export var _flame_area_name: StringName = &"Area3D"
@export var _ap_ignite_ratio: float = 0.20
## Période (s) de réorientation du cône vers sa cible.
@export var _aim_period: float = 0.1
## Portée (unités) au-delà de laquelle un ennemi n'est plus atteignable par les flammes.
@export var _flame_range: float = 4.0


func apply(ctx: SkillContext) -> void:
	var turret: TurretFireThrower = ctx.entity as TurretFireThrower
	if turret == null:
		Verbose.error("SE_BruleurDirectionnel: owner is not a TurretFireThrower", Verbose.Category.ENTITY_MODULE)
		return
	# État par tourelle (capturé par les closures), jamais sur l'effet partagé.
	var state := {&"target": null, &"vfx": null}
	turret.battle_callback_registry.register_periodic(&"BruleurDirectionnel", _tick_period, func() -> void:
		_burn_tick(turret)
	, true)
	turret.battle_callback_registry.register_periodic(&"BruleurDirectionnelAim", _aim_period, func() -> void:
		_aim_tick(turret, state)
	, true)


# Maintient une cible collante (anti-jitter), oriente le cône dessus et masque le VFX
# quand rien n'est atteignable.
func _aim_tick(turret: TurretFireThrower, state: Dictionary) -> void:
	var target: Entity = state[&"target"]
	if not _can_burn(turret, target):
		target = _acquire_target(turret)
		state[&"target"] = target

	_set_flame_visible(turret, state, target != null)
	if is_instance_valid(target):
		turret.look_at_target_y_only(target.get_collision_center())


# Une cible est valable tant qu'elle est vivante et dans la portée des flammes.
func _can_burn(turret: TurretFireThrower, enemy: Entity) -> bool:
	if not is_instance_valid(enemy) or enemy.is_dead():
		return false
	return turret.global_position.distance_to(enemy.get_collision_center()) <= _flame_range


func _acquire_target(turret: TurretFireThrower) -> Entity:
	var closest: Entity = turret.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	return closest if _can_burn(turret, closest) else null


# Affiche/masque le nœud porteur des flammes (parent de l'Area3D). Masquer ne coupe pas
# la détection de l'Area3D (la visibilité n'affecte pas la physique).
func _set_flame_visible(turret: TurretFireThrower, state: Dictionary, is_visible: bool) -> void:
	var vfx: Node3D = state[&"vfx"]
	if not is_instance_valid(vfx):
		var area := turret.find_child(String(_flame_area_name), true, false) as Area3D
		if area == null:
			return
		vfx = area.get_parent() as Node3D
		state[&"vfx"] = vfx
	if vfx != null and vfx.visible != is_visible:
		vfx.visible = is_visible


func _burn_tick(turret: TurretFireThrower) -> void:
	var area := turret.find_child(String(_flame_area_name), true, false) as Area3D
	if area == null:
		return

	var ap: float = turret.stats.get_stat(EntityStats.StatType.AP)
	var ignite_stacks: float = ap * _ap_ignite_ratio

	# Dégâts magiques uniquement si "Buse large" est actif (valeurs posées en meta).
	var buse_active: bool = turret.has_meta(META_BUSE_FLAT)
	var buse_damage: float = 0.0
	if buse_active:
		buse_damage = float(turret.get_meta(META_BUSE_FLAT)) + ap * float(turret.get_meta(META_BUSE_AP_RATIO))

	# Filtre faction via le système de ciblage éprouvé (liste _enemies déjà team-filtrée).
	var enemies := turret.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES)
	var bodies := area.get_overlapping_bodies()

	for body: Node3D in bodies:
		var enemy := body as Entity
		if enemy == null or not is_instance_valid(enemy) or enemy.is_dead():
			continue
		if not enemies.has(enemy):
			continue
		turret.alterations.direct_stack(enemy, ignite_stacks, Alteration.Type.IGNITE, &"Brûleur directionnel")
		if buse_active:
			turret.damage.direct(enemy, buse_damage, Utils.ActionType.DAMAGE_MAGICAL, &"Buse large")
