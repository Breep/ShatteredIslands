class_name SE_PetiteHorde
extends SkillEffect

# Talent "Petite horde": à la mort, donne _block Block à l'allié le plus proche.

@export var _block: float = 2.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := DeathModifier.new()
	modifier.id = &"PetiteHorde"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		var ally: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ALLY)
		if is_instance_valid(ally):
			chicken.alterations.direct_stack(ally, _block, Alteration.Type.BLOCK, &"Petite horde")
	chicken.death_modifiers_registry.register_modifier(modifier)


func get_description() -> String:
	return "À sa mort, donne " + _value(_block) + " [[BLOCK]] à l'allié le plus proche."
