class_name ActionModifiersDictionary
extends Resource

var _modifiers: Dictionary[StringName, ActionModifier]

func register_modifier(action_modifier: ActionModifier) -> void:
	Verbose.debug("Registering [" + action_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	if _modifiers.has(action_modifier.id):
		Verbose.error("register_modifier() - already knowns action modifier | " + str(action_modifier.id), Verbose.Category.ACTION_MODIFIER)
		return
	_modifiers[action_modifier.id] = action_modifier


func update_modifier(action_modifier: ActionModifier) -> void:
	Verbose.debug("Updating [" + action_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	_modifiers[action_modifier.id] = action_modifier


func unregister_modifier(action_modifier: ActionModifier) -> void:
	Verbose.debug("Unregistering [" + action_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	if not _modifiers.has(action_modifier.id):
		Verbose.error("unregister_modifier() - unknown action modifier | " + str(action_modifier.id), Verbose.Category.ACTION_MODIFIER)
		return


func get_all_modifiers() -> Array[ActionModifier]:
	return _modifiers.values().duplicate()


func consume_all_modifiers() -> Array[ActionModifier]:
	var modifiers: Array[ActionModifier] = _modifiers.values().duplicate()
	for mod_id: StringName in _modifiers.keys().duplicate():
		if _modifiers[mod_id].is_one_time_effect:
			_modifiers.erase(mod_id)
	return modifiers

func auto_cleanup() -> void:
	for modifier: ActionModifier in _modifiers.values().duplicate():
		if modifier.auto_cleanup:
			_modifiers.erase(modifier.id)
