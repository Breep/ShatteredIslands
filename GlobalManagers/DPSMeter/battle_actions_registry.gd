class_name BattleActionsRegistry
extends Node

class EntityRegistry extends Resource:
	var entity_name: String
	var action_registries: Dictionary[Utils.ActionType, ActionRegistry]
	
	func _init(ename: String) -> void:
		for action_type: Utils.ActionType in Utils.get_all_actions():
			action_registries[action_type] = ActionRegistry.new()
		entity_name = ename


class ActionRegistry extends Resource:
	var registry: Array[ActionData]


class ActionData extends Resource:
	var action_type: Utils.ActionType
	var timestamp: float
	var target_id: int
	var base_value: float
	var real_value: float
	var is_critical: float

var _entity_registries: Dictionary[int, EntityRegistry]

func register_action(timestamp:float, source: Entity, target: Entity, action_type: Utils.ActionType, base_value: float, real_value: float, is_critical: bool) -> void:
	var action_data := ActionData.new()
	print("[DEBUG_PROTO] register action ", timestamp)
	action_data.action_type = action_type
	action_data.timestamp = timestamp
	action_data.target_id = target.id
	action_data.base_value = base_value
	action_data.real_value = real_value
	action_data.is_critical = is_critical
	if not _entity_registries.has(source.id):
		_entity_registries[source.id] = EntityRegistry.new(source.name)
	
	_entity_registries[source.id].action_registries[action_type].registry.append(action_data)
