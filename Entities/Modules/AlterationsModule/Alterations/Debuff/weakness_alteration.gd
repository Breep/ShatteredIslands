class_name WeaknessAlteration
extends TypedStackAlteration

## Debuff typed stack: +FRAGILITY on the given ActionType per stack.


func _init() -> void:
	type = Type.WEAKNESS
	polarity = Polarity.DEBUFF
	id = &"Weakness"
	_stat_type = EntityStats.StatType.FRAGILITY
	_modifier_id = &"Weakness Alteration"
