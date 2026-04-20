class_name Stack
extends StackableAlteration

## Legacy base class for stack types (Poison, Ignite, Shield, Regen, Necrosis).
## Kept during rework transition — inherits _total_stacks / stacks_changed /
## add_stack / remove_stack / tick from StackableAlteration. Holds the legacy
## Type enum, colors and helpers used by ConditionsModule and UI panels.

class StackInfo extends Resource:
	var source: Entity
	var value: float
	var action_id: StringName

	func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
		source = p_source
		value = p_value
		action_id = p_action_id


enum Type {
	POISON,
	IGNITE,
	SHIELD,
	REGEN,
	NECROSIS
}

## Kept for backwards compatibility; prefer Alteration.ModifierType.
## Same int values, so mod dicts interoperate transparently.
enum ModifierType {
	DURATION,
}

const COLORS: Dictionary[Type, Color] = {
	Type.POISON: Color.WEB_GREEN,
	Type.SHIELD: Color.YELLOW,
	Type.IGNITE: Color.DARK_RED,
	Type.REGEN: Color.AQUAMARINE,
	Type.NECROSIS: Color.REBECCA_PURPLE
}


static func is_negative(stack_type: Type) -> bool:
	return stack_type in [Type.POISON, Type.IGNITE, Type.NECROSIS]


static func to_action(stack_type: Type) -> Utils.ActionType:
	match stack_type:
		Type.POISON: return Utils.ActionType.STACK_POISON
		Type.SHIELD: return Utils.ActionType.STACK_SHIELD
		Type.IGNITE: return Utils.ActionType.STACK_IGNITE
		Type.REGEN: return Utils.ActionType.STACK_REGEN
		Type.NECROSIS: return Utils.ActionType.STACK_NECROSIS
		_: return Utils.ActionType.STACK_POISON
