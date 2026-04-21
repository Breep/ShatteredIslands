class_name TimedStackAlteration
extends StackableAlteration

## Stackable alteration where each added batch has its own expiration time.
## Uses a ring buffer indexed by tick count; one slot per tick in the window.
## Used for: Regen.

class StackInfo extends Resource:
	var source: Entity
	var value: float
	var action_id: StringName

	func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
		source = p_source
		value = p_value
		action_id = p_action_id


enum { AMOUNT, STACK_INFOS }

const BUFFER_SIZE: int = 20

var _buffer: Array[Dictionary] = []
var _cursor: int = 0


func add_stack(amount: float, source: Entity = null, action_id: StringName = "", mod: Dictionary = {}) -> float:
	var duration: int = mod.get(Alteration.ModifierType.DURATION, 1)
	if amount <= 0: return total_stacks
	if _buffer.is_empty(): _init_buffer()

	duration = clampi(duration, 1, BUFFER_SIZE - 1)
	_total_stacks += amount

	var expiration_index: int = (_cursor + duration) % BUFFER_SIZE
	var slot: Dictionary = _buffer[expiration_index]
	slot[AMOUNT] += amount
	(slot[STACK_INFOS] as Array).append(StackInfo.new(source, amount, action_id))
	return total_stacks


func tick() -> float:
	if _buffer.is_empty(): return total_stacks

	var slot: Dictionary = _buffer[_cursor]
	var amount_to_expire: float = slot[AMOUNT]
	if amount_to_expire > 0:
		_total_stacks -= amount_to_expire
		slot[AMOUNT] = 0.0
		(slot[STACK_INFOS] as Array).clear()

	_cursor = (_cursor + 1) % BUFFER_SIZE
	return total_stacks


func _init_buffer() -> void:
	_buffer.clear()
	_buffer.resize(BUFFER_SIZE)
	for i in range(BUFFER_SIZE):
		_buffer[i] = {AMOUNT: 0.0, STACK_INFOS: []}
	_cursor = 0
