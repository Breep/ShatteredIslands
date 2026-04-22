class_name ThornAlteration
extends StackAlteration

## Buff stack: on each auto-attack received, the damage receiver reads
## `get_return_damage()` and returns that amount as PHYSICAL damage to the
## attacker. Stacks are persistent (no per-hit consumption).


func _init() -> void:
	type = Type.THORN
	polarity = Polarity.BUFF
	id = &"Thorn"


func get_return_damage() -> float:
	return _stacks
