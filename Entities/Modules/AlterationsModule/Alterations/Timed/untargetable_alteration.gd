class_name UntargetableAlteration
extends TimedAlteration

## Timed buff: the owner cannot be targeted directly while active (AOE damage
## still applies).


func _init() -> void:
	super._init()
	type = Type.UNTARGETABLE
	polarity = Polarity.BUFF
	id = &"Untargetable"
