class_name PoisonAlteration
extends StackAlteration

## Debuff stack. Every TICK_INTERVAL_SEC, deals `_stacks` POISON damage to the owner.

const TICK_INTERVAL_SEC: float = 2.0
const _INTERVAL_TICKS: int = int(TICK_INTERVAL_SEC * TICKS_PER_SECOND)

var _ticks_remaining: int = _INTERVAL_TICKS


func _init() -> void:
	type = Type.POISON
	polarity = Polarity.DEBUFF
	id = &"Poison"
	display_color = Color.WEB_GREEN
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/poison_stroke.svg")


func process_tick() -> void:
	_ticks_remaining -= 1
	if _ticks_remaining > 0: return
	_ticks_remaining = _INTERVAL_TICKS
	if _stacks <= 0 or _owner == null: return
	_owner.damage.take(_stacks, Utils.ActionType.DAMAGE_POISON, false, "Poison Periodic")
