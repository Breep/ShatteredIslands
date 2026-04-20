class_name BlockAlteration
extends SimpleStackAlteration

## Stackable BUFF alteration: each stack absorbs one instance of non-PURE
## incoming damage (including DoT ticks). Replaces the legacy
## `EntityStats.StatType.BLOCK` + `stats.block`.
##
## Consumption model: `try_consume(damage_type)` returns true if the instance
## was blocked. Non-PURE damage consumes 1 stack; PURE bypasses block.
## The damage receiver module drives this from its take_damage pipeline.


func _init() -> void:
	polarity = Polarity.BUFF
	id = &"Block"


## Attempt to consume 1 block stack against an incoming damage instance.
## Returns true if the damage should be fully blocked.
func try_consume(damage_type: Utils.ActionType) -> bool:
	if damage_type == Utils.ActionType.DAMAGE_PURE: return false
	if _total_stacks < 1: return false
	_total_stacks -= 1
	return true
