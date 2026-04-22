class_name DefenseAlteration
extends StackAlteration

## Buff stack: 1 stack = +1 RESISTANCE on every non-PURE damage type
## (PHYSICAL, MAGICAL, POISON). Maintains one ADD StatModifier per covered
## type, value synced with `_stacks`. Requires `bind(owner)` so the modifiers
## can be pushed to the entity's registry.

const COVERED_TYPES: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]

var _modifiers: Dictionary[Utils.ActionType, StatModifier] = {}


func _init() -> void:
	type = Type.DEFENSE
	polarity = Polarity.BUFF
	id = &"Defense"
	stacks_changed.connect(_on_stacks_changed)


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
			mod.id = &"Defense Alteration"
			mod.stat_type = EntityStats.StatType.RESISTANCE
			mod.action_type = action_type
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = new_stacks
			mod.tags = []
			_modifiers[action_type] = mod
			_owner.stat_modifiers_registry.register_modifier(mod)
		else:
			mod.value = new_stacks
			_owner.stat_modifiers_registry.register_modifier(mod)
