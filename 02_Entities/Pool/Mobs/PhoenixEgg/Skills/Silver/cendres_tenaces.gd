class_name SE_CendresTenacesOeuf
extends SkillEffect

# Talent "Cendres tenaces" (Œuf): l'œuf gagne +_hp_percent % de PV max.

@export var _hp_percent: float = 60.0


func apply(ctx: SkillContext) -> void:
	var egg: Entity = ctx.entity
	var modifier := StatModifier.new()
	modifier.id = &"CendresTenacesOeuf"
	modifier.stat_type = EntityStats.StatType.HEALTH_MAX
	modifier.calc_type = StatModifier.CalcType.MULT
	modifier.value = _hp_percent / 100.0
	egg.stat_modifiers_registry.register_modifier(modifier)
