class_name SE_ThornyLegacy
extends SkillEffect

## Talent 3 "Héritage épineux": à sa mort, transfère _transfer_percent % de ses stacks
## de Thorn à l'allié le plus proche.

@export var _transfer_percent: float = 25.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	var mod := DeathModifier.new()
	mod.id = &"Thorny Legacy"
	mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		var thorn: float = _owner.alterations.get_stacks(Alteration.Type.THORN)
		var transferred: float = thorn * _transfer_percent / 100.0
		if transferred <= 0: return
		var ally: Entity = _owner.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ALLY)
		if is_instance_valid(ally):
			ally.alterations.add_stack(Alteration.Type.THORN, transferred)

	_owner.death_modifiers_registry.register_modifier(mod)


func get_description() -> String:
	return "À sa mort, transfère " + _value(_transfer_percent) + "% de ses stacks de " \
		+ "Thorn à l'allié le plus proche."
