class_name IgniteAlteration
extends StackAlteration

## Debuff stack. Every TICK_INTERVAL_SEC, deals `_stacks` MAGICAL damage,
## then decays with a hybrid rule: max(DECAY_MIN, stacks × DECAY_PERCENT).

const TICK_INTERVAL_SEC: float = 1.0
const DECAY_PERCENT: float = 15.0
const DECAY_MIN: int = 2
const _INTERVAL_TICKS: int = int(TICK_INTERVAL_SEC * TICKS_PER_SECOND)

var _ticks_remaining: int = _INTERVAL_TICKS


func _init() -> void:
	type = Type.IGNITE
	polarity = Polarity.DEBUFF
	id = &"Ignite"
	display_color = Color.ORANGE_RED
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/ignite_stroke.svg")


func process_tick() -> void:
	_ticks_remaining -= 1
	if _ticks_remaining > 0: return
	_ticks_remaining = _INTERVAL_TICKS
	if _stacks <= 0 or _owner == null: return

	_owner.damage.take(_stacks, Utils.ActionType.DAMAGE_MAGICAL, false, "Ignite Periodic")
	_decay()


func _decay() -> void:
	if _stacks <= 0: return
	var decay: int = max(DECAY_MIN, int(_stacks * DECAY_PERCENT / 100.0))
	_stacks -= decay
