class_name ProgressionComponent
extends EntityComponent

const DEFAULT_LEVEL_REFS: Dictionary[int, int] = {
	1: 0,
	2: 100,
	3: 200,
	4: 300,
	5: 500,
	6: 700,
	7: 900,
	8: 1100,
	9: 1300,
	10: 1500,
	11: 1700,
	12: 1900,
	13: 2200,
	14: 2500,
	15: 2800,
	16: 3200,
	17: 3600,
	18: 4100,
	19: 4700,
	20: 5500,
}

signal level_changed(new_level: int)
var _level: int = 1
var level: int:
	get: return _level
	set(value):
		if value == _level: return
		_level = value
		_handle_level_up()
		level_changed.emit(_level)

signal xp_changed(new_xp: int)
var _xp: int = 0
var xp: int:
	get: return _xp
	set(value):
		if value == _xp: return
		_xp = value
		xp_changed.emit(_xp)


func _enter_tree() -> void:
	if _owner == null: return
	if _owner.progression != null and _owner.progression != self:
		Verbose.trace("Override: ProgressionComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.progression.queue_free()
	_owner.progression = self


func _ready() -> void:
	super._ready()
	_handle_level_up()
	level = _owner.level


func _handle_level_up() -> void:
	if _owner.override_base_stats != null:
		_owner.stat_modifiers_registry.update_base_stats(_owner.override_base_stats)
		return
	
	if _owner.entity_desc != null and _owner.entity_desc.stats.has(level):
		_owner.stat_modifiers_registry.update_base_stats(_owner.entity_desc.stats[level])
	else:
		_owner.stat_modifiers_registry.update_base_stats(null)



 
