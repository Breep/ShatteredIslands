class_name ActionModifiersDictionary
extends Resource

var _modifiers: Dictionary[StringName, ActionModifier]

func register_modifier(action_modifier: ActionModifier) -> void:
	if _modifiers.has(action_modifier.id):
		printerr("ActionModifiersDictionary: register_modifier() - already knowns action modifier \"", action_modifier.id, "\"")
		return
	_modifiers[action_modifier.id] = action_modifier


func update_modifier(action_modifier: ActionModifier) -> void:
	_modifiers[action_modifier.id] = action_modifier


func unregister_modifier(action_modifier: ActionModifier) -> void:
	if not _modifiers.has(action_modifier.id):
		printerr("ActionModifiersDictionary: unregister_modifier() - unknown action modifier \"", action_modifier.id, "\"")
		return


func get_all_modifiers() -> Array[ActionModifier]:
	return _modifiers.values().duplicate()


func consume_all_modifiers() -> Array[ActionModifier]:
	var modifiers: Array[ActionModifier] = _modifiers.values().duplicate()
	for mod_id: StringName in _modifiers.keys().duplicate():
		if _modifiers[mod_id].is_one_time_effect:
			_modifiers.erase(mod_id)
	return modifiers
