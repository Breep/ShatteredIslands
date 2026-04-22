class_name SilenceAlteration
extends TimedAlteration

## Timed debuff: spells, projectiles (non-auto), and summons are suppressed
## while active. Auto-attacks remain allowed.


func _init() -> void:
	super._init()
	type = Type.SILENCE
	polarity = Polarity.DEBUFF
	id = &"Silence"
