class_name Stack
extends Resource

class StackInfo extends Resource:
	var source: Entity
	var value: float
	var action_id: StringName

	func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
		source = p_source
		value = p_value
		action_id = p_action_id


signal stacks_changed(new_stacks: float)
var _total_stacks: float = 0
var total_stacks: float:
	get: return _total_stacks
	set(value):
		if value == _total_stacks: return
		_total_stacks = max(0, value)
		stacks_changed.emit(_total_stacks)

enum Type {
	POISON,
	IGNITE,
	ARMOR,
	REGEN,
	NECROSIS
}
