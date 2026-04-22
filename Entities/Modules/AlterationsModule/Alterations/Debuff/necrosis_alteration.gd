class_name NecrosisAlteration
extends StackAlteration

## Debuff stack. Maintains a StatModifier ADD on RESISTANCE / UTILITY_HEAL in
## sync with `_stacks`: heal received is reduced by (100+EXPOSURE)/(100+RESISTANCE).

var _heal_resistance_mod: StatModifier


func _init() -> void:
	type = Type.NECROSIS
	polarity = Polarity.DEBUFF
	id = &"Necrosis"
	display_color = Color.REBECCA_PURPLE
	stacks_changed.connect(_on_stacks_changed)


func _on_stacks_changed(new_value: float) -> void:
	if _owner == null or _owner.stat_modifiers_registry == null: return
	if new_value <= 0:
		if _heal_resistance_mod != null:
			_owner.stat_modifiers_registry.unregister_modifier(_heal_resistance_mod)
			_heal_resistance_mod = null
		return
	if _heal_resistance_mod == null:
		_heal_resistance_mod = StatModifier.new()
		_heal_resistance_mod.id = &"Necrosis"
		_heal_resistance_mod.stat_type = EntityStats.StatType.RESISTANCE
		_heal_resistance_mod.action_type = Utils.ActionType.UTILITY_HEAL
		_heal_resistance_mod.calc_type = StatModifier.CalcType.ADD
		_heal_resistance_mod.tags = []
	_heal_resistance_mod.value = new_value
	_owner.stat_modifiers_registry.register_modifier(_heal_resistance_mod)
