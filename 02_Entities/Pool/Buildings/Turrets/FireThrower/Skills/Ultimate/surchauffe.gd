class_name SE_Surchauffe
extends SkillEffect

# Ultimate "Surchauffe": pendant _duration s, la tourelle stoppe son lance-flamme
# (dégâts périodiques du passif + VFX) et n'attaque plus, mais se soigne de
# AP x _heal_ap_ratio PV par seconde.

@export var _duration: float = 3.0
@export var _heal_ap_ratio: float = 2.0
@export var _fire_node_name: StringName = &"fire"


func apply(ctx: SkillContext) -> void:
	var turret: TurretFireThrower = ctx.entity as TurretFireThrower
	if turret == null:
		Verbose.error("SE_Surchauffe: owner is not a TurretFireThrower", Verbose.Category.ENTITY_MODULE)
		return

	# Coupe le lance-flamme : dégâts (périodiques), VFX (masqué) et auto-attaque.
	turret.battle_callback_registry.pause_timers()
	var flame_vfx := _get_flame_vfx(turret)
	if flame_vfx != null:
		flame_vfx.visible = false
	if turret.auto_attack != null:
		turret.auto_attack.set_paused(true)

	# Soin par seconde, lu en live (bénéficie de "Fournaise contrôlée"). Les oneshots ne
	# sont pas affectés par pause_timers().
	for second: int in range(1, int(_duration) + 1):
		turret.battle_callback_registry.register_oneshot(float(second), func() -> void:
			var ap: float = turret.stats.get_stat(EntityStats.StatType.AP)
			turret.heal.direct(turret, ap * _heal_ap_ratio, &"Surchauffe")
		)

	# Fin de la surchauffe : on relance dégâts, VFX et auto-attaque.
	turret.battle_callback_registry.register_oneshot(_duration, func() -> void:
		turret.battle_callback_registry.resume_timers()
		if flame_vfx != null:
			flame_vfx.visible = true
		if turret.auto_attack != null:
			turret.auto_attack.set_paused(false)
	)


func _get_flame_vfx(turret: TurretFireThrower) -> Node3D:
	# La racine du VFX de flammes = parent du node de particules "fire".
	var fire := turret.find_child(String(_fire_node_name), true, false)
	if fire == null:
		return null
	return fire.get_parent() as Node3D
