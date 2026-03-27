class_name IgniteStack
extends SimpleStack

## Ignite stack with decay logic
## Decays by a percentage each tick

const IGNITE_DECAY_PERCENT: float = 15.0

const IGNITE_DECAY_MIN: int = 5
const IGNITE_DECAY_MAX: int = 10000

func tick() -> float:
	if _total_stacks > 0:
		var decay: int = (_total_stacks * IGNITE_DECAY_PERCENT / 100.0) as int
		decay = clampi(decay, IGNITE_DECAY_MIN, IGNITE_DECAY_MAX)
		_total_stacks -= decay
	return _total_stacks
