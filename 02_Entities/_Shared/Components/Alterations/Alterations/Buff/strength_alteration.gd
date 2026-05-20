class_name StrengthAlteration
extends TypedStackAlteration

## Buff typed stack: +POWER on the given ActionType per stack.


func _init() -> void:
	type = Type.STRENGTH
	polarity = Polarity.BUFF
	id = &"Strength"
	icon = preload("res://02_Entities/_Shared/Components/Alterations/AlterationIcon/Icons/strength_weakness_icon.png")
	display_color = Color.ORANGE
	_stat_type = EntityStats.StatType.M_POWER
	_modifier_id = &"Strength Alteration"
