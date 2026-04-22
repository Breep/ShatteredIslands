class_name InvulnerableAlteration
extends StateAlteration

## State buff: the owner takes no damage while active.


func _init() -> void:
	stackable = false
	type = Type.INVULNERABLE
	polarity = Polarity.BUFF
	id = &"Invulnerable"
