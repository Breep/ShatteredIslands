class_name SE_CriticalEye
extends SkillEffect

@export var _crit_bonus: float = 10.0

func apply(ctx: SkillContext) -> void:
	var _owner = ctx.entity
	
	var mod := StatModifier.new()
	mod.stat_type = EntityStats.StatType.CRIT_CHANCE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.id = &"Critical Eye"
	mod.value = _crit_bonus
	_owner.stat_modifiers_registry.register_modifier(mod)
