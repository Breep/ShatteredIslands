class_name SE_CrocsToxiques
extends SkillEffect

# Talent "Crocs toxiques": chaque auto-attaque applique _stacks stacks de Poison à la cible.

@export var _stacks: float = 6.0


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	var modifier := AutoAttackModifier.new()
	modifier.id = &"CrocsToxiques"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if is_instance_valid(target):
			golem.alterations.direct_stack(target, _stacks, Alteration.Type.POISON, &"Crocs toxiques")
	golem.auto_attack_modifier_registry.register_modifier(modifier)


func get_description() -> String:
	return "Chaque auto-attaque applique " + _value(_stacks) + " [[POISON_STACK]] à la cible."
