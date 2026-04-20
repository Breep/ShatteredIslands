class_name AbsorbingStackAlteration
extends StackableAlteration

## Stackable alteration that absorbs incoming damage.
## Per-ActionType efficiency coefficients determine which damage types are
## mitigated; an optional free-use chance may skip stack consumption.
## Used for: Shield.

signal stack_broken(amount: float)

var _efficiencies: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 1.0,
	Utils.ActionType.DAMAGE_MAGICAL: 1.0,
	Utils.ActionType.DAMAGE_POISON: 0.0,
	Utils.ActionType.DAMAGE_PURE: 0.0,
}

var _free_use_chance: float = 0.0


func set_efficiency(damage_type: Utils.ActionType, efficiency: float) -> void:
	_efficiencies[damage_type] = clamp(efficiency, 0.0, 1.0)


func set_free_use_chance(chance: float) -> void:
	_free_use_chance = clamp(chance, 0.0, 100.0)


func add_stack(amount: float, _source: Entity = null, _action_id: StringName = "", _mod: Dictionary = {}) -> float:
	_total_stacks += amount
	return _total_stacks


func remove_stack(amount: float) -> float:
	_total_stacks -= amount
	return _total_stacks


func get_reduced_damage_taken(damage: float, damage_type: Utils.ActionType, battle_id: int = -1) -> float:
	if _total_stacks <= 0: return damage

	var efficiency: float = _efficiencies.get(damage_type, 0.0)
	if efficiency == 0: return damage

	var blockable_damage: float = _total_stacks
	var damage_reduction: float = min(damage, blockable_damage) * efficiency
	var damage_reduced: float = damage - damage_reduction

	if _free_use_chance > 0 and Utils.is_randomize_modifier_active(_free_use_chance, battle_id):
		return damage_reduced

	var shield_broken_amount: float = damage_reduction
	_total_stacks -= shield_broken_amount
	stack_broken.emit(shield_broken_amount)
	return damage_reduced
