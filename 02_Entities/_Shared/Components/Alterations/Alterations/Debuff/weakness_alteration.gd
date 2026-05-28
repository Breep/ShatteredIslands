class_name WeaknessAlteration
extends TypedStackAlteration

## Debuff typed stack: +FRAGILITY on the given ActionType per stack.


func _init() -> void:
	type = Type.WEAKNESS
	polarity = Polarity.DEBUFF
	id = &"Weakness"
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/defense_stroke.svg")
	display_color = Color.SLATE_GRAY
	_stat_type = EntityStats.StatType.M_FRAGILITY
	_modifier_id = &"Weakness Alteration"
