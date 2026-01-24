class_name IgniteStack
extends SimpleStack

## Ignite stack with decay logic
## Decays by a percentage each tick

const IGNITE_DECAY_PERCENT: float = 20.0

func tick() -> float:
	if _total_stacks > 0:
		var decay: int = (_total_stacks * IGNITE_DECAY_PERCENT / 100.0) as int
		decay = clampi(decay, 1, decay)
		_total_stacks -= decay
	return _total_stacks
