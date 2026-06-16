class_name SE_BruleurDirectionnel
extends SkillEffect

# Passif "Brûleur directionnel": toutes les _tick_period s, applique AP x _ap_ignite_ratio
# stacks d'Ignite à tous les ennemis présents dans la hitbox des flammes (collision shape
# de l'Area3D). De base le passif ne fait QUE de l'Ignite. Le talent "Buse large" active en
# plus des dégâts magiques, dont les valeurs sont posées en meta par SE_BuseLarge.
# La tourelle pivote en continu (toutes les _aim_period s) pour garder son cône braqué
# sur l'ennemi le plus proche.

const META_BUSE_FLAT := &"firethrower_buse_flat"
const META_BUSE_AP_RATIO := &"firethrower_buse_ap_ratio"

@export var _tick_period: float = 1.0
@export var _flame_area_name: StringName = &"Area3D"
@export var _ap_ignite_ratio: float = 0.20
## Période (s) de réorientation du cône vers l'ennemi le plus proche.
@export var _aim_period: float = 0.1


func apply(ctx: SkillContext) -> void:
	var turret: TurretFireThrower = ctx.entity as TurretFireThrower
	if turret == null:
		Verbose.error("SE_BruleurDirectionnel: owner is not a TurretFireThrower", Verbose.Category.ENTITY_MODULE)
		return
	turret.battle_callback_registry.register_periodic(&"BruleurDirectionnel", _tick_period, func() -> void:
		_burn_tick(turret)
	, true)
	turret.battle_callback_registry.register_periodic(&"BruleurDirectionnelAim", _aim_period, func() -> void:
		_aim_at_closest(turret)
	, true)


# Pivote la tourelle vers l'ennemi le plus proche (y only) pour que son cône le suive.
func _aim_at_closest(turret: TurretFireThrower) -> void:
	var closest: Entity = turret.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(closest):
		return
	turret.look_at_target_y_only(closest.get_collision_center())


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
		turret.alterations.inflict_condition_stacks(enemy, ignite_stacks, Alteration.Type.IGNITE, &"Brûleur directionnel")
		if buse_active:
			turret.damage.direct(enemy, buse_damage, Utils.ActionType.DAMAGE_MAGICAL, &"Buse large")
