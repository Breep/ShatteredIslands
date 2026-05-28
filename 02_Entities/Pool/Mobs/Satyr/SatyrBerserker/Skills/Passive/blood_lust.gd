class_name SE_BloodLust
extends SkillEffect

@export var _base_lifesteal_amount_percent: float = 10.0
@export var _scale_lifesteal_amount_percent: float = 2.0

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	var mod := StatModifier.new()
	mod.id = &"BloodLust"
	mod.stat_type = EntityStats.StatType.LIFESTEAL
	mod.value = _base_lifesteal_amount_percent + _owner.progression.level * _scale_lifesteal_amount_percent
	_owner.stat_modifiers_registry.register_modifier(mod)
