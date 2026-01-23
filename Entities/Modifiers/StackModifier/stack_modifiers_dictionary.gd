class_name StackModifiersDictionary
extends Resource

var _modifiers: Dictionary[StringName, StackModifier]

func register_modifier(stack_modifier: StackModifier) -> void:
	Verbose.debug("Registering [" + stack_modifier.id + "]", Verbose.Category.STACK_MODIFIER)
	if _modifiers.has(stack_modifier.id):
		Verbose.error("register_modifier() - already known stack modifier | " + str(stack_modifier.id), Verbose.Category.STACK_MODIFIER)
		return
	_modifiers[stack_modifier.id] = stack_modifier


func update_modifier(stack_modifier: StackModifier) -> void:
	Verbose.debug("Updating [" + stack_modifier.id + "]", Verbose.Category.STACK_MODIFIER)
	_modifiers[stack_modifier.id] = stack_modifier


func unregister_modifier(stack_modifier: StackModifier) -> void:
	Verbose.debug("Unregistering [" + stack_modifier.id + "]", Verbose.Category.STACK_MODIFIER)
	if not _modifiers.has(stack_modifier.id):
		Verbose.error("unregister_modifier() - unknown stack modifier | " + str(stack_modifier.id), Verbose.Category.STACK_MODIFIER)
		return
	_modifiers.erase(stack_modifier.id)


func get_all_modifiers() -> Array[StackModifier]:
	return _modifiers.values().duplicate()


func consume_all_modifiers() -> Array[StackModifier]:
	var modifiers: Array[StackModifier] = _modifiers.values().duplicate()
	for mod_id: StringName in _modifiers.keys().duplicate():
		if _modifiers[mod_id].is_one_time_effect:
			_modifiers.erase(mod_id)
	return modifiers

func auto_cleanup() -> void:
	for modifier: StackModifier in _modifiers.values().duplicate():
		if modifier.auto_cleanup:
			_modifiers.erase(modifier.id)
