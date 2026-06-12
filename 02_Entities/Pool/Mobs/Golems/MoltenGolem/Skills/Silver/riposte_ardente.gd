class_name SE_RiposteArdente
extends SkillEffect

# Talent "Riposte ardente": à chaque auto-attaque reçue, inflige _stacks stacks d'Ignite à
# l'attaquant.

@export var _stacks: float = 6.0


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	golem.action_received.connect(func(source: Entity, _action_type: Utils.ActionType, action_id: StringName, _value: float, _is_critical: bool) -> void:
		if action_id != &"auto_attack":
			return
		if not is_instance_valid(source):
			return
		golem.alterations.inflict_condition_stacks(source, _stacks, Alteration.Type.IGNITE, &"Riposte ardente")
	)


func get_description() -> String:
	return "Chaque auto-attaque subie applique " + _value(_stacks) + " stacks d'[[IGNITE]] à l'attaquant."
