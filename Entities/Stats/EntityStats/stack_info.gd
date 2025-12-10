class_name StackInfo
extends Resource

@export var source: Entity
@export var value: float
@export var action_id: StringName

func _init(p_source: Entity = null, p_value: float = 0.0, p_action_id: StringName = "") -> void:
	source = p_source
	value = p_value
	action_id = p_action_id
