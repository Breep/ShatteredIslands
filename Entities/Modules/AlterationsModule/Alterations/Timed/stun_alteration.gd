class_name StunAlteration
extends TimedAlteration

## Timed debuff: all auto-attacks, spells, projectiles, and summons are
## suppressed while active.


func _init() -> void:
	super._init()
	type = Type.STUN
	polarity = Polarity.DEBUFF
	id = &"Stun"
