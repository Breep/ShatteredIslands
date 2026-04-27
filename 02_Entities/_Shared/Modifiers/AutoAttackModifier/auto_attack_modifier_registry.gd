class_name AutoAttackModifierRegistry
extends Resource

var _auto_attack_modifiers: Dictionary[StringName, AutoAttackModifier]

# ============================== Public functions ==============================

func register_modifier(modifier: AutoAttackModifier) -> void:
	_auto_attack_modifiers[modifier.id] = modifier


func unregister_modifier(modifier_id: StringName) -> void:
	if not _auto_attack_modifiers.has(modifier_id):
		printerr("StatModifierDictionary: unregister_modifier() - unknown stat modifier \"", modifier_id, "\" [", get_path(), "]")
		return
	
	_auto_attack_modifiers.erase(modifier_id)


func get_all_modifiers() -> Array[AutoAttackModifier]:
	return _auto_attack_modifiers.values()


func consume_all_modifiers() -> Array[AutoAttackModifier]:
	var modifiers: Array[AutoAttackModifier] = _auto_attack_modifiers.values().duplicate()
	for mod_id: StringName in _auto_attack_modifiers.keys().duplicate():
		if _auto_attack_modifiers[mod_id].is_one_time_effect:
			_auto_attack_modifiers.erase(mod_id)
	return modifiers
