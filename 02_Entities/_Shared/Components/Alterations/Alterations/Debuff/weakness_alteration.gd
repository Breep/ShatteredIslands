class_name WeaknessAlteration
extends StatStackAlteration

## Debuff stack: 1 stack = +1 FRAGILITY on every non-PURE damage type (PHYSICAL,
## MAGICAL, POISON), reducing outgoing damage. Mutually exclusive with Strength —
## applying one cancels the other (see AlterationsComponent netting).


func _init() -> void:
	type = Type.WEAKNESS
	polarity = Polarity.DEBUFF
	id = &"Weakness"
	display_color = Color.SLATE_GRAY
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/weakness2.svg")
	icon_modulate = Color.CRIMSON
	_stat_type = EntityStats.StatType.M_FRAGILITY
	_modifier_id = &"Weakness Alteration"
	stacks_changed.connect(_on_stacks_changed)
