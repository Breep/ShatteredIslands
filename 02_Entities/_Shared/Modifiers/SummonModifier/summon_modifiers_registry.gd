class_name SummonModifiersRegistry
extends Node

var _modifiers: Dictionary[StringName, SummonModifier]

#var auto_attack_modifier: AutoAttackModifier
#var summon_modifier: ActionModifier
#var stat_modifier: StatModifier

func register_modifier(summon_modifier: SummonModifier) -> void:
	Verbose.debug("Registering [" + summon_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	_modifiers[summon_modifier.id] = summon_modifier


func unregister_modifier(summon_modifier: SummonModifier) -> void:
	Verbose.debug("Unregistering [" + summon_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	if not _modifiers.has(summon_modifier.id):
		Verbose.error("unregister_modifier() - unknown action modifier | " + str(summon_modifier.id), Verbose.Category.ACTION_MODIFIER)
		return
	_modifiers.erase(summon_modifier.id)


func get_all_modifiers() -> Array[SummonModifier]:
	return _modifiers.values().duplicate()


func consume_all_modifiers() -> Array[SummonModifier]:
	var modifiers: Array[SummonModifier] = _modifiers.values().duplicate()
	for mod_id: StringName in _modifiers.keys().duplicate():
		if _modifiers[mod_id].is_one_time_effect:
			_modifiers.erase(mod_id)
	return modifiers


func auto_cleanup() -> void:
	for modifier: SummonModifier in _modifiers.values().duplicate():
		if modifier.auto_cleanup:
			_modifiers.erase(modifier.id)
