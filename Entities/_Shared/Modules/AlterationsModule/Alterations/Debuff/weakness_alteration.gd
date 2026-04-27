class_name WeaknessAlteration
extends TypedStackAlteration

## Debuff typed stack: +FRAGILITY on the given ActionType per stack.


func _init() -> void:
	type = Type.WEAKNESS
	polarity = Polarity.DEBUFF
	id = &"Weakness"
	icon = preload("res://Entities/_Shared/Modules//AlterationsModule/AlterationIcon/Icons/strength_weakness_icon.png")
	display_color = Color.SLATE_GRAY
	_stat_type = EntityStats.StatType.FRAGILITY
	_modifier_id = &"Weakness Alteration"
