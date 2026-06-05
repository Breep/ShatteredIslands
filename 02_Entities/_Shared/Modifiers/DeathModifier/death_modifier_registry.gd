class_name DeathModifiersRegistry
extends Node


var _modifiers: Dictionary[StringName, DeathModifier]

func register_modifier(death_modifier: DeathModifier) -> void:
	Verbose.debug("Registering [" + death_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	_modifiers[death_modifier.id] = death_modifier


func unregister_modifier(death_modifier: DeathModifier) -> void:
	Verbose.debug("Unregistering [" + death_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	if not _modifiers.has(death_modifier.id):
		Verbose.error("unregister_modifier() - unknown action modifier | " + str(death_modifier.id), Verbose.Category.ACTION_MODIFIER)
		return
	_modifiers.erase(death_modifier.id)


func get_all_modifiers() -> Array[DeathModifier]:
	return _modifiers.values().duplicate()


func consume_all_modifiers() -> Array[DeathModifier]:
	var modifiers: Array[DeathModifier] = _modifiers.values().duplicate()
	for mod_id: StringName in _modifiers.keys().duplicate():
		if _modifiers[mod_id].is_one_time_effect:
			_modifiers.erase(mod_id)
	return modifiers
