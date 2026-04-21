class_name SimpleStackAlteration
extends StackableAlteration

## Stackable alteration with no decay or expiration.
## Stacks are added/removed explicitly and persist until cleared.
## Used for: Poison, Necrosis, and (after rework) Strength, Defense, Weakness,
## Vulnerability, Block, Thorn.

func add_stack(amount: float, _source: Entity = null, _action_id: StringName = "", _mod: Dictionary = {}) -> float:
	_total_stacks += amount
	return _total_stacks


func remove_stack(amount: float) -> float:
	_total_stacks -= amount
	return _total_stacks
