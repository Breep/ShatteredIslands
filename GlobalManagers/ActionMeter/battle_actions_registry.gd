class_name BattleActionsRegistry
extends Node

class EntityActionsRegistry extends Resource:
	var entity_name: String
	var actions_meters: Dictionary[Utils.ActionType, float]
	var actions_data: Dictionary[StringName, ActionData]
	var critical_number: Dictionary[StringName, int]
	
	func _init(ename: String) -> void:
		entity_name = ename
		for action_type: Utils.ActionType in Utils.get_all_actions():
			actions_meters[action_type] = 0.0
	
	func register_action(action_id: StringName, action_type: Utils.ActionType, value: float, is_critical: bool) -> void:
		actions_meters[action_type] += value
		if not actions_data.has(action_id): actions_data[action_id] = ActionData.new(action_id)
		if not critical_number.has(action_id): critical_number[action_id] = 0
		actions_data[action_id].register_action(action_type, value)
		if is_critical: critical_number[action_id] += 1


class ActionData extends Resource:
	var action_id: StringName
	var action_meters: Dictionary[Utils.ActionType, float]
	
	func _init(id: StringName) -> void:
		action_id = id
		for action_type: Utils.ActionType in Utils.get_all_actions():
			action_meters[action_type] = 0.0
	
	func register_action(action_type: Utils.ActionType, value: float) -> void:
		action_meters[action_type] += value


var _entity_actions_registries: Dictionary[int, EntityActionsRegistry]


func register_action(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	if not _entity_actions_registries.has(source.id):
		_entity_actions_registries[source.id] = EntityActionsRegistry.new(source.name)
	
	_entity_actions_registries[source.id].register_action(action_id, action_type, value, is_critical)
