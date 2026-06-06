class_name SE_CoupsGelants
extends SkillEffect

# Talent "Coups gelants": chaque auto-attaque a _chance_percent % d'appliquer STUN
# _stun_duration s sur la cible.

@export var _chance_percent: float = 50.0
@export var _stun_duration: float = 1.0


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	var modifier := AutoAttackModifier.new()
	modifier.id = &"CoupsGelants"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target):
			return
		if not Utils.is_randomize_modifier_active(_chance_percent, golem.battle_id):
			return
		golem.alterations.inflict_status(target, Alteration.Type.STUN, _stun_duration, &"Coups gelants")
	golem.auto_attack_modifier_registry.register_modifier(modifier)
