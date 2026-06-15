class_name SE_Opportuniste
extends SkillEffect

# Talent "Opportuniste": +_bonus_percent % de dégâts contre les ennemis sous _hp_threshold
# de leurs PV.

@export var _bonus_percent: float = 30.0
@export var _hp_threshold: float = 0.35


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := AutoAttackModifier.new()
	modifier.id = &"Opportuniste"
	modifier.is_one_time_effect = false
	modifier.damage_modifier_callback = func(data: Dictionary) -> void:
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target) or target.stats.health_max <= 0.0:
			return
		if target.stats.health / target.stats.health_max <= _hp_threshold:
			data[AutoAttackModifier.VarType.DAMAGE_MUL] += _bonus_percent
	chicken.auto_attack_modifier_registry.register_modifier(modifier)
