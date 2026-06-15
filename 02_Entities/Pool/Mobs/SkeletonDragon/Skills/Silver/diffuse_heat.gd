class_name SE_DiffuseHeat
extends SkillEffect

# Silver "Chaleur diffuse": every _period seconds, apply Ignite stacks to every
# enemy on the board.

@export var _period: float = 4.0
@export var _ignite_stacks: float = 30.0

func apply(ctx: SkillContext) -> void:
	var owner: Entity = ctx.entity

	owner.battle_callback_registry.register_periodic(&"DiffuseHeat", _period, func() -> void:
		for enemy: Entity in owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
			if is_instance_valid(enemy):
				owner.alterations.inflict_condition_stacks(enemy, _ignite_stacks, Alteration.Type.IGNITE, &"DiffuseHeat")
	, true)


func get_description() -> String:
	return "Toutes les " + _value(_period) + " s, applique " + _value(_ignite_stacks) \
		+ " stacks d'[[IGNITE]] à tous les ennemis."
