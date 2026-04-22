class_name IgniteAlteration
extends StackAlteration

## Debuff stack. Every TICK_INTERVAL_SEC, deals MAXHP_PERCENT_PER_STACK × stacks
## of max-HP MAGICAL damage, then decays by DECAY_PERCENT (clamped).

const TICK_INTERVAL_SEC: float = 1.0
const MAXHP_PERCENT_PER_STACK: float = 0.03
const DECAY_PERCENT: float = 15.0
const DECAY_MIN: int = 1
const DECAY_MAX: int = 10000
const _INTERVAL_TICKS: int = int(TICK_INTERVAL_SEC * TICKS_PER_SECOND)

var _ticks_remaining: int = _INTERVAL_TICKS


func _init() -> void:
	type = Type.IGNITE
	polarity = Polarity.DEBUFF
	id = &"Ignite"


func process_tick() -> void:
	_ticks_remaining -= 1
	if _ticks_remaining > 0: return
	_ticks_remaining = _INTERVAL_TICKS
	if _stacks <= 0 or _owner == null: return

	var percent: float = MAXHP_PERCENT_PER_STACK * _stacks
	_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.ActionType.DAMAGE_MAGICAL, false, "Ignite Periodic")
	_decay()


func _decay() -> void:
	if _stacks <= 0: return
	var decay: int = int(_stacks * DECAY_PERCENT / 100.0)
	decay = clampi(decay, DECAY_MIN, DECAY_MAX)
	_stacks -= decay
