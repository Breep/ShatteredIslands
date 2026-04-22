class_name StrengthAlteration
extends TypedStackAlteration

## Buff typed stack: +POWER on the given ActionType per stack.


func _init() -> void:
	type = Type.STRENGTH
	polarity = Polarity.BUFF
	id = &"Strength"
	_stat_type = EntityStats.StatType.POWER
	_modifier_id = &"Strength Alteration"
