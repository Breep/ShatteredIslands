class_name WeaknessAlteration
extends Alteration

## Stackable DEBUFF alteration: per-ActionType stacks that push StatModifier
## ADD on FRAGILITY. Replaces card-driven StatModifier manipulation on
## FRAGILITY; permanent passives still use the registry path directly.

signal typed_stacks_changed(action_type: Utils.ActionType, new_value: float)

var _owner: Entity
var _stacks: Dictionary[Utils.ActionType, float] = {}
var _modifiers: Dictionary[Utils.ActionType, StatModifier] = {}


func _init() -> void:
	polarity = Polarity.DEBUFF
	id = &"Weakness"


func bind(owner: Entity) -> void:
	_owner = owner


func get_stacks(action_type: Utils.ActionType) -> float:
	return _stacks.get(action_type, 0.0)


func add_stack(action_type: Utils.ActionType, amount: float) -> float:
	return _set_stacks(action_type, get_stacks(action_type) + amount)


func remove_stack(action_type: Utils.ActionType, amount: float) -> float:
	return _set_stacks(action_type, max(0.0, get_stacks(action_type) - amount))


func _set_stacks(action_type: Utils.ActionType, new_stacks: float) -> float:
	if action_type == Utils.ActionType.DAMAGE_PURE:
		return 0.0
	new_stacks = max(0.0, new_stacks)
	_stacks[action_type] = new_stacks
	_sync_modifier(action_type, new_stacks)
	typed_stacks_changed.emit(action_type, new_stacks)
	return new_stacks


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
		mod.id = &"Weakness Alteration"
		mod.stat_type = EntityStats.StatType.FRAGILITY
		mod.action_type = action_type
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = new_value
		mod.tags = []
		_modifiers[action_type] = mod
		_owner.stat_modifiers_registry.register_modifier(mod)
	else:
		mod.value = new_value
		_owner.stat_modifiers_registry.register_modifier(mod)
