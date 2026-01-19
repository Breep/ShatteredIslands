class_name StackInfo
extends Resource

var source: Entity
var value: float
var action_id: StringName

func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
	source = p_source
	value = p_value
	action_id = p_action_id
