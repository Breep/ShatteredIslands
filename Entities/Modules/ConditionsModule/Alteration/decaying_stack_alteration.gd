class_name DecayingStackAlteration
extends SimpleStackAlteration

## Stackable alteration that loses a fraction of its stacks on each tick.
## Used for: Ignite.

@export_range(0.0, 100.0) var decay_percent: float = 15.0
@export var decay_min: int = 1
@export var decay_max: int = 10000


func tick() -> float:
	if _total_stacks > 0:
		var decay: int = (_total_stacks * decay_percent / 100.0) as int
		decay = clampi(decay, decay_min, decay_max)
		_total_stacks -= decay
	return _total_stacks
