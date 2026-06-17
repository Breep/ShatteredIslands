class_name SE_MiniBatterie
extends SkillEffect

# Passif "Mini-batterie": à chaque attaque, donne _shield Shield à l'allié le plus blessé.

@export var _shield: float = 10.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := AutoAttackModifier.new()
	modifier.id = &"MiniBatterie"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(_data: Dictionary) -> void:
		var ally: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
		if is_instance_valid(ally):
			chicken.alterations.inflict_condition_stacks(ally, _shield, Alteration.Type.SHIELD, &"Mini-batterie")
	chicken.auto_attack_modifier_registry.register_modifier(modifier)


func get_description() -> String:
	return "À chaque attaque, donne " + _value(_shield) + " [[SHIELD]] à l'allié le plus blessé."
