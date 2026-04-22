class_name StackAlteration
extends Alteration

## Alteration whose state is a float stack count.
## Default semantics: add_stack accumulates, remove_stack subtracts, tick is a
## no-op. Subclasses override to implement per-type behavior
## (decay, expiration, absorption, typed dispatch, stat modifiers, …).

signal stacks_changed(new_stacks: float)

var _stacks: float = 0.0:
	set(value):
		var clamped: float = max(0.0, value)
		if clamped == _stacks: return
		_stacks = clamped
		stacks_changed.emit(_stacks)

var stacks: float:
	get: return _stacks


func add_stack(amount: float, _source: Entity = null, _action_id: StringName = "", _mod: Dictionary = {}) -> float:
	if amount <= 0: return _stacks
	if stackable:
		_stacks += amount
	else:
		_stacks = amount
	return _stacks


func remove_stack(amount: float, _mod: Dictionary = {}) -> float:
	if amount <= 0: return _stacks
	_stacks -= amount
	return _stacks


func clear() -> void:
	_stacks = 0.0
