class_name FightingPhaseData
extends Resource

var action_meters: Dictionary[Utils.ActionType, ActionMeter]

func _init() -> void:
	for action_type: Utils.ActionType in Utils.get_all_actions():
		action_meters[action_type] = ActionMeter.new()
		action_meters[action_type].action_type = action_type
