class_name SE_SurchargeFinale
extends SkillEffect

# Talent "Surcharge finale": à la mort, donne AP x _ap_ratio Shield à l'allié le plus blessé.

@export var _ap_ratio: float = 1.5


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := DeathModifier.new()
	modifier.id = &"SurchargeFinale"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		var ally: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
		if is_instance_valid(ally):
			var shield: float = chicken.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
			chicken.alterations.inflict_condition_stacks(ally, shield, Alteration.Type.SHIELD, &"Surcharge finale")
	chicken.death_modifiers_registry.register_modifier(modifier)


func get_description() -> String:
	return "À sa mort, donne [[SHIELD]] égal à " + _value(_ap_ratio) \
		+ "× son [[AP]] à l'allié le plus blessé."
