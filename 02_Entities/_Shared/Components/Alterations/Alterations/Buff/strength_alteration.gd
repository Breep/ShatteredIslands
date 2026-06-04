class_name StrengthAlteration
extends StatStackAlteration

## Buff stack: 1 stack = +1 POWER on every non-PURE damage type (PHYSICAL,
## MAGICAL, POISON), increasing outgoing damage. Mutually exclusive with
## Weakness — applying one cancels the other (see AlterationsComponent netting).


func _init() -> void:
	type = Type.STRENGTH
	polarity = Polarity.BUFF
	id = &"Strength"
	display_color = Color.STEEL_BLUE
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/strength2.svg")
	icon_modulate = Color.ORANGE
	_stat_type = EntityStats.StatType.M_POWER
	_modifier_id = &"Strength Alteration"
	stacks_changed.connect(_on_stacks_changed)
