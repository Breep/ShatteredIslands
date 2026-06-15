class_name TauntAlteration
extends StateAlteration

## State debuff: target is prioritized by enemy targeting.

func _init() -> void:
	stackable = false
	type = Type.TAUNT
	polarity = Polarity.DEBUFF
	id = &"Taunt"
	display_color = Color.CRIMSON
	display_mode = DisplayMode.CUSTOM
