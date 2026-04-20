class_name DefenseAlteration
extends SimpleStackAlteration

## Stackable BUFF alteration: 1 stack = +1 RESISTANCE on all non-PURE damage
## types (PHYSICAL, MAGICAL, POISON). Replaces the legacy
## `EntityStats.StatType.DEFENCE` + hardcoded DEFENCE↔RESISTANCE coupling.
##
## Mechanism: maintains a single ADD StatModifier per non-PURE ActionType,
## with value kept in sync with `total_stacks`. The modifier is registered on
## first non-zero stack and kept registered while stacks > 0 (the registry
## recomputes on value changes).
##
## The alteration is bound to an owning Entity via `bind()` so it can push
## StatModifiers onto the entity's registry. Call `bind()` from the module
## that owns the alteration instance.

const COVERED_TYPES: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]

var _owner: Entity
var _modifiers: Dictionary[Utils.ActionType, StatModifier] = {}


func _init() -> void:
	polarity = Polarity.BUFF
	id = &"Defense"
	stacks_changed.connect(_on_stacks_changed)


func bind(owner: Entity) -> void:
	_owner = owner


func _on_stacks_changed(new_stacks: float) -> void:
	if _owner == null: return
	if _owner.stat_modifiers_registry == null: return

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
