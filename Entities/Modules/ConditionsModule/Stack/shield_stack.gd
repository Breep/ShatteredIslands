class_name ShieldStack
extends Stack

signal shield_stack_broken(amount: float)

var _efficiencies: Dictionary[Utils.DamageType, float] = {
	Utils.DamageType.PHYSICAL: 1.0,
	Utils.DamageType.MAGICAL: 1.0,
	Utils.DamageType.POISON: 0.0,
	Utils.DamageType.PURE: 0.0,
}

var _free_use_chance: float = 0.0


## Set the efficiency for blocking a specific damage type (0.0 = no block, 1.0 = full block)
## Example: set_efficiency(Utils.DamageType.POISON, 0.5) means shield blocks 50% of poison damage
func set_efficiency(damage_type: Utils.DamageType, efficiency: float) -> void:
	_efficiencies[damage_type] = clamp(efficiency, 0.0, 1.0)


## Set the chance that shield is not consumed when blocking damage (0.0 = always consumed, 1.0 = never consumed)
func set_free_use_chance(chance: float) -> void:
	_free_use_chance = clamp(chance, 0.0, 100.0)


func add_stack(amount: float, source: Entity = null, action_id: StringName = "", mod: Dictionary = {}) -> float:
	_total_stacks += amount
	return _total_stacks


func remove_stack(amount: float) -> float:
	_total_stacks -= amount
	return _total_stacks


func tick() -> float:
	return _total_stacks


func get_reduced_damage_taken(damage: float, damage_type: Utils.DamageType) -> float:
	if _total_stacks <= 0: return damage
	
	var efficiency: float = _efficiencies.get(damage_type, 0.0)
	if efficiency == 0: return damage
	
	var blockable_damage: float = _total_stacks
	var damage_reduction: float = min(damage, blockable_damage) * efficiency
	var damage_reduced: float = damage - damage_reduction
	
	# Check if shield is consumed (Absorption Matrix logic)
	if _free_use_chance > 0 and Utils.is_randomize_modifier_active(_free_use_chance):
		return damage_reduced
	
	# Consume shield
	var shield_broken_amount: float = damage_reduction
	_total_stacks -= shield_broken_amount
	shield_stack_broken.emit(shield_broken_amount)
	return damage_reduced
