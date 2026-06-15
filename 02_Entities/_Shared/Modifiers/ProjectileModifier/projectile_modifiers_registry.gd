class_name ProjectileModifiersRegistry
extends Node

var _modifiers: Dictionary[StringName, ProjectileModifier]

func register_modifier(projectile_modifier: ProjectileModifier) -> void:
	Verbose.debug("Registering [" + projectile_modifier.id + "]", Verbose.Category.ACTION_MODIFIER)
	_modifiers[projectile_modifier.id] = projectile_modifier


func unregister_modifier(projectile_modifier_id: StringName) -> void:
	Verbose.debug("Unregistering [" + projectile_modifier_id + "]", Verbose.Category.ACTION_MODIFIER)
	if not _modifiers.has(projectile_modifier_id):
		Verbose.error("unregister_modifier() - unknown action modifier | " + str(projectile_modifier_id), Verbose.Category.ACTION_MODIFIER)
		return
	_modifiers.erase(projectile_modifier_id)


func get_all_modifiers() -> Array[ProjectileModifier]:
	return _modifiers.values().duplicate()


func consume_all_modifiers() -> Array[ProjectileModifier]:
	var modifiers: Array[ProjectileModifier] = _modifiers.values().duplicate()
	for mod_id: StringName in _modifiers.keys().duplicate():
		if _modifiers[mod_id].is_one_time_effect:
			_modifiers.erase(mod_id)
	return modifiers
