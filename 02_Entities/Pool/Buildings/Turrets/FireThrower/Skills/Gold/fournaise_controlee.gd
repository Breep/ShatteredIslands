class_name SE_FournaiseControlee
extends SkillEffect

# Talent "Fournaise contrôlée": chaque cast de l'ultimate augmente l'AP de la tourelle
# de _ap_per_cast (cumulatif). Réinitialisé à la fin de chaque combat.

@export var _ap_per_cast: float = 50.0


func apply(ctx: SkillContext) -> void:
	var turret: TurretFireThrower = ctx.entity as TurretFireThrower
	if turret == null:
		Verbose.error("SE_FournaiseControlee: owner is not a TurretFireThrower", Verbose.Category.ENTITY_MODULE)
		return

	# Boxed pour vivre par instance (la resource SkillEffect peut être partagée).
	var bonus: Array[float] = [0.0]

	turret.ultimate_casted.connect(func() -> void:
		bonus[0] += _ap_per_cast
		var modifier := StatModifier.new()
		modifier.id = &"FournaiseControlee"
		modifier.stat_type = EntityStats.StatType.AP
		modifier.value = bonus[0]
		turret.stat_modifiers_registry.register_modifier(modifier)
	)

	turret.battle_callback_registry.register_battle_end(&"FournaiseControleeReset", func() -> void:
		if bonus[0] == 0.0:
			return
		bonus[0] = 0.0
		turret.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AP, "FournaiseControlee")
	)
