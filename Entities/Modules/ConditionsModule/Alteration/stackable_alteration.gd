class_name StackableAlteration
extends Alteration

## Abstract base for stackable alterations.
## Each instance holds a float stack count; subclasses define how stacks are
## added, removed, and decayed/expired over time.

signal stacks_changed(new_stacks: float)

var _total_stacks: float = 0:
	set(value):
		if value == _total_stacks: return
		_total_stacks = max(0, value)
		stacks_changed.emit(_total_stacks)

var total_stacks: float:
	get: return _total_stacks


## Virtual: add stacks. `mod` may contain keys from Alteration.ModifierType.
## Returns the new total stack count.
func add_stack(_amount: float, _source: Entity = null, _action_id: StringName = "", _mod: Dictionary = {}) -> float:
	return _total_stacks


## Virtual: remove stacks.
## Returns the new total stack count.
func remove_stack(_amount: float) -> float:
	return _total_stacks


## Virtual: called periodically; subclasses implement decay/expiration logic.
## Returns the new total stack count.
func tick() -> float:
	return _total_stacks
