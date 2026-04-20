class_name ThornAlteration
extends SimpleStackAlteration

## Stackable BUFF alteration: on each auto-attack received, returns
## `total_stacks` physical damage to the attacker. Replaces the legacy
## `EntityStats.StatType.THORN` + `stats.thorn`.
##
## Trigger model: `get_return_damage()` returns the amount to retaliate with
## (0 if no stacks). The damage receiver module drives this from the
## auto-attack branch of take_damage. Stacks are persistent (no per-hit
## consumption) — mirrors legacy behavior where thorn was a flat stat.


func _init() -> void:
	polarity = Polarity.BUFF
	id = &"Thorn"


## Returns the retaliation damage amount for an auto-attack received.
## Thorn does not consume stacks per hit (persistent buff).
func get_return_damage() -> float:
	return _total_stacks
