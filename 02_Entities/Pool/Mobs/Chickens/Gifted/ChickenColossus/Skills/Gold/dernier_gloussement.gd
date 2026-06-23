class_name SE_DernierGloussement
extends SkillEffect

# Talent "Dernier gloussement": à la mort, les alliés dans un rayon _radius gagnent _thorn
# Thorn.

@export var _thorn: float = 1.0
@export var _radius: float = 4.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := DeathModifier.new()
	modifier.id = &"DernierGloussement"
	modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		for ally: Entity in chicken.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius):
			chicken.alterations.direct_stack(ally, _thorn, Alteration.Type.THORN, &"Dernier gloussement")
	chicken.death_modifiers_registry.register_modifier(modifier)


func get_description() -> String:
	return "À sa mort, les alliés dans un rayon de " + _value(_radius) + " gagnent " \
		+ _value(_thorn) + " [[THORN]]."
