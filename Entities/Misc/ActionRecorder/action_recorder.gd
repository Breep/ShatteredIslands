class_name ActionRecorder
extends Node

var _entity_owner: Entity

func _init(entity_owner: Entity) -> void:
	_entity_owner = entity_owner
	_entity_owner.action_done.connect(_on_entity_owner_action_done)


func _on_entity_owner_action_done(entity_ref: Entity, target: Entity, action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	if entity_ref != _entity_owner: return
	_record_action(target, action_type, base_value, real_value)


func _record_action(target: Entity, action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	pass
