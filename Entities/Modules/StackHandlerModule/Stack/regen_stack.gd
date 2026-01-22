class_name RegenStack
extends Stack

# Ring Buffer for Regen tracking
# Array of Dictionaries: { "amount": float, "stack_infos": Array[StackInfo] }

enum {
	AMOUNT,
	STACK_INFOS
}

const BUFFER_SIZE: int = 20

var _buffer: Array[Dictionary] = []
var _cursor: int = 0

#region ============================== Public functions ==============================
func add_stack(amount: float, duration: int, source: Entity, action_id: StringName) -> float:
	if amount <= 0: return total_stacks
	if _buffer.is_empty(): _init_buffer()
	
	duration = clampi(duration, 1, BUFFER_SIZE - 1)
	
	# Add to current total
	total_stacks += amount
	
	# Schedule expiration
	var expiration_index: int = (_cursor + duration) % BUFFER_SIZE
	var slot: Dictionary = _buffer[expiration_index]
	
	slot[AMOUNT] += amount
	(slot[STACK_INFOS] as Array).append(StackInfo.new(source, amount, action_id))
	return total_stacks


func tick() -> float:
	if _buffer.is_empty(): return total_stacks
	
	# Process expiration at current cursor
	var slot: Dictionary = _buffer[_cursor]
	var amount_to_expire: float = slot[AMOUNT]
	
	if amount_to_expire > 0:
		total_stacks -= amount_to_expire
		# Clear slot
		slot[AMOUNT] = 0.0
		(slot[STACK_INFOS] as Array).clear()
	
	# Move cursor
	_cursor = (_cursor + 1) % BUFFER_SIZE
	return total_stacks
#endregion

#region ============================== Private functions ==============================
func _init_buffer() -> void:
	_buffer.clear()
	_buffer.resize(BUFFER_SIZE)
	for i in range(BUFFER_SIZE):
		_buffer[i] = {AMOUNT: 0.0, STACK_INFOS: []}
	_cursor = 0
#endregion
