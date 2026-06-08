class_name SE_BuseLarge
extends SkillEffect

# Talent "Buse large": les flammes infligent aussi _flat_damage + AP x _ap_damage_ratio
# dégâts magiques. De base le passif ne fait que de l'Ignite ; ce talent active les dégâts
# magiques en posant ses valeurs en meta, lues par le passif (SE_BruleurDirectionnel).

@export var _flat_damage: float = 4.0
@export var _ap_damage_ratio: float = 0.25


func apply(ctx: SkillContext) -> void:
	var turret: TurretFireThrower = ctx.entity as TurretFireThrower
	if turret == null:
		Verbose.error("SE_BuseLarge: owner is not a TurretFireThrower", Verbose.Category.ENTITY_MODULE)
		return
	turret.set_meta(SE_BruleurDirectionnel.META_BUSE_FLAT, _flat_damage)
	turret.set_meta(SE_BruleurDirectionnel.META_BUSE_AP_RATIO, _ap_damage_ratio)
