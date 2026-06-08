class_name SE_CalibrationRange
extends SkillEffect

# Talent "Calibration": la tourelle gagne +_range_bonus de portée d'attaque.

@export var _range_bonus: float = 2.0


func apply(ctx: SkillContext) -> void:
	var turret: GammaTurret = ctx.entity as GammaTurret
	if turret == null:
		Verbose.error("SE_CalibrationRange: owner is not a GammaTurret", Verbose.Category.ENTITY_MODULE)
		return
	var modifier := StatModifier.new()
	modifier.id = &"CalibrationRange"
	modifier.stat_type = EntityStats.StatType.AR
	modifier.value = _range_bonus
	turret.stat_modifiers_registry.register_modifier(modifier)
