class_name DefenseAlteration
extends StatStackAlteration

## Buff stack: 1 stack = +1 RESISTANCE on every non-PURE damage type (PHYSICAL,
## MAGICAL, POISON), reducing incoming damage. Mutually exclusive with
## Vulnerability — applying one cancels the other (see AlterationsComponent).


func _init() -> void:
	type = Type.DEFENSE
	polarity = Polarity.BUFF
	id = &"Defense"
	display_color = Color.STEEL_BLUE
	icon = preload("res://04_UI/_Themes/Data/Icons/AlterationsIcons/defense4.svg")
	icon_modulate = Color.DODGER_BLUE
	_stat_type = EntityStats.StatType.M_RESISTANCE
	_modifier_id = &"Defense Alteration"
	stacks_changed.connect(_on_stacks_changed)
