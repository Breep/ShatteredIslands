class_name RegenAlteration
extends StackAlteration

## Buff stack. Each batch of added stacks has its own expiration window
## (ring buffer, one slot per regen-tick). On each regen-tick the slot at
## the current cursor expires, the cursor advances, and if stacks remain the
## owner is healed by the current stack total.

class StackInfo extends Resource:
	var source: Entity
	var value: float
	var action_id: StringName

	func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
		source = p_source
		value = p_value
		action_id = p_action_id


const BUFFER_SIZE: int = 20
const TICK_INTERVAL_SEC: float = 1.0
const _INTERVAL_TICKS: int = int(TICK_INTERVAL_SEC * TICKS_PER_SECOND)
const AMOUNT_KEY: StringName = &"amount"
const INFOS_KEY: StringName = &"infos"

var _buffer: Array[Dictionary] = []
var _cursor: int = 0
var _ticks_remaining: int = _INTERVAL_TICKS


func _init() -> void:
	type = Type.REGEN
	polarity = Polarity.BUFF
	id = &"Regen"
	display_color = Color.AQUAMARINE
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/regen2.svg")
	icon_modulate = Color.AQUAMARINE


func add_stack(amount: float, source: Entity = null, action_id: StringName = "", mod: Dictionary = {}) -> float:
	if amount <= 0: return _stacks
	if _buffer.is_empty(): _init_buffer()

	var duration: int = mod.get(Alteration.ModifierType.DURATION, 1)
	duration = clampi(duration, 1, BUFFER_SIZE - 1)
	_stacks += amount

	var idx: int = (_cursor + duration) % BUFFER_SIZE
	var slot: Dictionary = _buffer[idx]
	slot[AMOUNT_KEY] += amount
	(slot[INFOS_KEY] as Array).append(StackInfo.new(source, amount, action_id))
	return _stacks


func process_tick() -> void:
	_ticks_remaining -= 1
	if _ticks_remaining > 0: return
	_ticks_remaining = _INTERVAL_TICKS

	_expire_current_slot()

	if _stacks <= 0 or _owner == null: return
	_owner.heal.direct(_owner, _stacks, "Regen")


func _expire_current_slot() -> void:
	if _buffer.is_empty(): return
	var slot: Dictionary = _buffer[_cursor]
	var amount: float = slot[AMOUNT_KEY]
	if amount > 0:
		_stacks -= amount
		slot[AMOUNT_KEY] = 0.0
		(slot[INFOS_KEY] as Array).clear()
	_cursor = (_cursor + 1) % BUFFER_SIZE


func _init_buffer() -> void:
	_buffer.clear()
	_buffer.resize(BUFFER_SIZE)
	for i in range(BUFFER_SIZE):
		_buffer[i] = {AMOUNT_KEY: 0.0, INFOS_KEY: []}
	_cursor = 0
