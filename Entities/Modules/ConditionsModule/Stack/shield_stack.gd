class_name ShieldStack
extends Stack

signal shield_stack_broken(amount: float)

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
	var efficiency: float = _efficiencies.get(damage_type, 0.0)
	if efficiency == 0:
		return damage
	
	var blockable_damage: float = _total_stacks * efficiency
	var damage_reduction: float = min(damage, blockable_damage)
	var damage_reduced: float = damage - damage_reduction
	if _free_use_chance > 0 and Utils.is_randomize_modifier_active(_free_use_chance):
		return damage_reduced
	var shield_broken_amount: float = damage_reduction / efficiency
	_total_stacks -= shield_broken_amount
	shield_stack_broken.emit(shield_broken_amount)
	return damage_reduced