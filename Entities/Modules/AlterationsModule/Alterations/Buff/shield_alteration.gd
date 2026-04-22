class_name ShieldAlteration
extends StackAlteration

## Buff stack. Absorbs incoming damage with a per-ActionType efficiency.
## Optional `_free_use_chance` RNG skips stack consumption on a hit.

signal shield_broken(amount: float)

var _efficiencies: Dictionary[Utils.ActionType, float] = {
	Utils.ActionType.DAMAGE_PHYSICAL: 1.0,
	Utils.ActionType.DAMAGE_MAGICAL: 1.0,
	Utils.ActionType.DAMAGE_POISON: 0.0,
	Utils.ActionType.DAMAGE_PURE: 0.0,
}

var _free_use_chance: float = 0.0


func _init() -> void:
	type = Type.SHIELD
	polarity = Polarity.BUFF
	id = &"Shield"
	display_color = Color.YELLOW
	display_mode = DisplayMode.CUSTOM


func set_efficiency(damage_type: Utils.ActionType, efficiency: float) -> void:
	_efficiencies[damage_type] = clamp(efficiency, 0.0, 1.0)


func set_free_use_chance(chance: float) -> void:
	_free_use_chance = clamp(chance, 0.0, 100.0)


func get_reduced_damage_taken(damage: float, damage_type: Utils.ActionType, battle_id: int = -1) -> float:
	if _stacks <= 0: return damage
	var efficiency: float = _efficiencies.get(damage_type, 0.0)
	if efficiency == 0: return damage

	var blockable: float = _stacks
	var reduction: float = min(damage, blockable) * efficiency
	var reduced: float = damage - reduction
	if _free_use_chance > 0 and Utils.is_randomize_modifier_active(_free_use_chance, battle_id):
		return reduced
	_stacks -= reduction
	shield_broken.emit(reduction)
	return reduced
