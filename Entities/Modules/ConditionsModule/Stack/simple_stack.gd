class_name SimpleStack
extends Stack

## Simple stack implementation that stores a single float value
## Used for: Poison, Necrosis

func add_stack(amount: float, _source: Entity = null, _action_id: StringName = "", _mod: Dictionary = {}) -> float:
	_total_stacks += amount
	return _total_stacks


func remove_stack(amount: float) -> float:
	_total_stacks -= amount
	return _total_stacks


func tick() -> float:
	return _total_stacks
