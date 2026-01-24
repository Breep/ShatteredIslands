class_name Stack
extends Resource

## Base class for all stack types
## Each stack type must implement: add_stack, remove_stack, tick

class StackInfo extends Resource:
	var source: Entity
	var value: float
	var action_id: StringName

	func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
		source = p_source
		value = p_value
		action_id = p_action_id


signal stacks_changed(new_stacks: float)
var _total_stacks: float = 0:
	set(value):
		if value == _total_stacks: return
		_total_stacks = max(0, value)
		stacks_changed.emit(_total_stacks)
var total_stacks: float:
	get: return _total_stacks

enum Type {
	POISON,
	IGNITE,
	SHIELD,
	REGEN,
	NECROSIS
}

enum ModifierType {
	DURATION,
}


## Add stacks with optional modifiers
## Returns the new total stack count
func add_stack(_amount: float, _source: Entity = null, _action_id: StringName = "", _mod: Dictionary = {}) -> float:
	return _total_stacks


## Remove stacks
## Returns the new total stack count
func remove_stack(_amount: float) -> float:
	return _total_stacks


## Called periodically to update stack state (decay, expiration, etc.)
## Returns the new total stack count
func tick() -> float:
	return _total_stacks
