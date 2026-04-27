class_name TypedStackAlteration
extends StackAlteration

## Stack alteration keyed by Utils.ActionType — one float count per action type.
## The inherited `_stacks` tracks the SUM of all per-action-type counts, so
## aggregate helpers (`get_total_stacks`, …) keep working. Subclasses set
## `_stat_type` / `_modifier_id` / `_polarity` to decide which stat is pushed.
##
## Callers pass the target ActionType via the `mod` dict:
##   add_stack(amount, source, action_id, {Alteration.ModifierType.ACTION_TYPE: Utils.ActionType.DAMAGE_PHYSICAL})
## DAMAGE_PURE is rejected.

signal typed_stacks_changed(action_type: Utils.ActionType, new_value: float)

# Supplied by subclass in _init().
var _stat_type: EntityStats.StatType
var _modifier_id: StringName = &""

var _typed_stacks: Dictionary[Utils.ActionType, float] = {}
var _modifiers: Dictionary[Utils.ActionType, StatModifier] = {}


func get_typed_stacks(action_type: Utils.ActionType) -> float:
	return _typed_stacks.get(action_type, 0.0)


func add_stack(amount: float, _source: Entity = null, _action_id: StringName = "", mod: Dictionary = {}) -> float:
	var action_type: int = mod.get(Alteration.ModifierType.ACTION_TYPE, -1)
	if action_type == -1:
		Verbose.error("TypedStackAlteration.add_stack: missing ACTION_TYPE in mod", Verbose.Category.ENTITY_MODULE)
		return _stacks
	_set_typed(action_type, get_typed_stacks(action_type) + amount)
	return _stacks


func remove_stack(amount: float, mod: Dictionary = {}) -> float:
	var action_type: int = mod.get(Alteration.ModifierType.ACTION_TYPE, -1)
	if action_type == -1:
		Verbose.error("TypedStackAlteration.remove_stack: missing ACTION_TYPE in mod", Verbose.Category.ENTITY_MODULE)
		return _stacks
	_set_typed(action_type, max(0.0, get_typed_stacks(action_type) - amount))
	return _stacks


func _set_typed(action_type: Utils.ActionType, new_value: float) -> void:
	if action_type == Utils.ActionType.DAMAGE_PURE: return
	new_value = max(0.0, new_value)
	var old_value: float = _typed_stacks.get(action_type, 0.0)
	if old_value == new_value: return
	_typed_stacks[action_type] = new_value
	_stacks = _stacks + (new_value - old_value)
	_sync_modifier(action_type, new_value)
	typed_stacks_changed.emit(action_type, new_value)


func _sync_modifier(action_type: Utils.ActionType, new_value: float) -> void:
	if _owner == null or _owner.stat_modifiers_registry == null: return
	var mod: StatModifier = _modifiers.get(action_type)
	if new_value <= 0:
		if mod != null:
			_owner.stat_modifiers_registry.unregister_modifier(mod)
			_modifiers.erase(action_type)
		return
	if mod == null:
		mod = StatModifier.new()
		mod.id = _modifier_id
		mod.stat_type = _stat_type
		mod.action_type = action_type
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = new_value
		mod.tags = []
		_modifiers[action_type] = mod
		_owner.stat_modifiers_registry.register_modifier(mod)
	else:
		mod.value = new_value
		_owner.stat_modifiers_registry.register_modifier(mod)
