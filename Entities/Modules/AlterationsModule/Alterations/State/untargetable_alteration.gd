class_name UntargetableAlteration
extends StateAlteration

## State buff: the owner cannot be targeted directly while active (AOE damage
## still applies).


func _init() -> void:
	stackable = false
	type = Type.UNTARGETABLE
	polarity = Polarity.BUFF
	id = &"Untargetable"
