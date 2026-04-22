class_name InvulnerableAlteration
extends TimedAlteration

## Timed buff: the owner takes no damage while active.


func _init() -> void:
	super._init()
	type = Type.INVULNERABLE
	polarity = Polarity.BUFF
	id = &"Invulnerable"
