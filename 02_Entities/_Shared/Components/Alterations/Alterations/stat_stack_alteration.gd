class_name StatStackAlteration
extends StackAlteration

## Stack alteration that maintains one ADD StatModifier per non-PURE damage type
## (PHYSICAL, MAGICAL, POISON), each synced to the current stack count. Backs the
## four broad combat alterations: Strength/Weakness (M_POWER / M_FRAGILITY) and
## Defense/Vulnerability (M_RESISTANCE / M_EXPOSURE). Subclasses set `_stat_type`
## and `_modifier_id` in `_init()` and connect `stacks_changed` to
## `_on_stacks_changed`. Single-type targeting is NOT done here — it goes through
## the raw stat lever (AlterationsComponent.add_typed_stack).

const COVERED_TYPES: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]

var _stat_type: EntityStats.StatType
var _modifier_id: StringName = &""

var _modifiers: Dictionary[Utils.ActionType, StatModifier] = {}


func _on_stacks_changed(new_stacks: float) -> void:
	if _owner == null or _owner.stat_modifiers_registry == null: return

	for action_type: Utils.ActionType in COVERED_TYPES:
		var mod: StatModifier = _modifiers.get(action_type)
		if new_stacks <= 0:
			if mod != null:
				_owner.stat_modifiers_registry.unregister_modifier(mod)
				_modifiers.erase(action_type)
			continue

		if mod == null:
			mod = StatModifier.new()
			mod.id = _modifier_id
			mod.stat_type = _stat_type
			mod.action_type = action_type
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = new_stacks
			mod.tags = []
			_modifiers[action_type] = mod
			_owner.stat_modifiers_registry.register_modifier(mod)
		else:
			mod.value = new_stacks
			_owner.stat_modifiers_registry.register_modifier(mod)
