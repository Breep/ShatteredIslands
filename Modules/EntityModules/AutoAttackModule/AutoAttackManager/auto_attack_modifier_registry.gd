class_name AutoAttackModifierRegistry
extends Node

var _auto_attack_modifiers: Dictionary[StringName, AutoAttackModifier]

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public functions ==============================

func register_modifier(modifier: AutoAttackModifier) -> void:
	if _auto_attack_modifiers.has(modifier.id):
		printerr("StatModifierDictionary: register_modifier() - already known stat modifier \"", modifier.id, "\" [", get_path(), "]")
		return
	
	_auto_attack_modifiers[modifier.id] = modifier


func update_modifier(modifier: AutoAttackModifier) -> void:
	pass


func unregister_modifier(modifier_id: StringName) -> void:
	_auto_attack_modifiers.erase(modifier_id)


func get_all_modifiers() -> Array[AutoAttackModifier]:
	return _auto_attack_modifiers.values()


func consume_all_modifiers() -> Array[AutoAttackModifier]:
	var modifiers: Array[AutoAttackModifier] = _auto_attack_modifiers.values().duplicate()
	for mod_id: StringName in _auto_attack_modifiers.keys().duplicate():
		if _auto_attack_modifiers[mod_id].is_one_time_effect:
			_auto_attack_modifiers.erase(mod_id)
	return modifiers
