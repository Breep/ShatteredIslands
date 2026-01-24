class_name SimpleStack
extends Stack

## Simple stack implementation that stores a single float value
## Used for: Poison, Necrosis

func add_stack(amount: float, source: Entity = null, action_id: StringName = "", mod: Dictionary = {}) -> float:
	_total_stacks += amount
	return _total_stacks


func remove_stack(amount: float) -> float:
	_total_stacks -= amount
	return _total_stacks


func tick() -> float:
	return _total_stacks
