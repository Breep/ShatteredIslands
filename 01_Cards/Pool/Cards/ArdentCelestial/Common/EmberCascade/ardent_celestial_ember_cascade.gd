class_name ArdentCelestialEmberCascade
extends CardEffect

## Ardent Celestial — pour chaque stack d'ignite infligé par le héros, une chance
## de tirer un projectile d'abilité aléatoire depuis son pool.

@export var _chance_per_stack: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance_per_stack[card_lvl - 1]
	
	var mod := ActionModifier.new()
	mod.id = card_name
	mod.action_type = Utils.ActionCategory.STACK
	mod.is_one_time_effect = false
	mod.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.STACK_TYPE) != Alteration.Type.IGNITE: return
		if not is_instance_valid(owner) or owner.projectile == null: return
		var stacks: int = int(cb_vars.get(ActionModifier.VarType.STACK_VALUE, 0))
		for i in stacks:
			if not Utils.is_randomize_modifier_active(chance, owner.battle_id): continue
			var target: Entity = owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
			if target != null and is_instance_valid(target):
				owner.projectile.fire_random(target, owner)
	owner.action_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var mod := ActionModifier.new()
	mod.id = card_name
	mod.action_type = Utils.ActionCategory.STACK
	ctx.entity_owner.action_modifiers_registry.unregister_modifier(mod)


func get_description(card_lvl: int) -> String:
	return "Application d'[[IGNITE]] : " + _value(_chance_per_stack[card_lvl - 1]) \
		+ "% chance de déclencher un [[ABILITY_PROJECTILE]]"
