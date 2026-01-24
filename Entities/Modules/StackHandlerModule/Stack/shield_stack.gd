class_name ShieldStack
extends Stack

var _efficiencies: Dictionary[Utils.DamageType, float] = {
	Utils.DamageType.PHYSICAL: 1.0,
	Utils.DamageType.MAGICAL: 1.0,
	Utils.DamageType.POISON: 0,
    Utils.DamageType.PURE: 0,
}

var _free_use_chance: float = 0.0

func add_stack(amount: float, source: Entity = null, action_id: StringName = "", mod: Dictionary = {}) -> float:
	_total_stacks += amount
	return _total_stacks


func remove_stack(amount: float) -> float:
	_total_stacks -= amount
	return _total_stacks


func tick() -> float:
	return _total_stacks


func get_reduced_damage_taken(damage: float, damage_type: Utils.DamageType) -> float:
	var damage_reduction = min(damage, _total_stacks * _efficiencies.get(damage_type, 0.0))
	var damage_reduced = damage - damage_reduction
	if _free_use_chance > 0 and Utils.is_randomize_modifier_active(_free_use_chance):
		return damage_reduced
	_total_stacks -= damage_reduction
	return damage_reduced