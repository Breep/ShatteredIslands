class_name CharacterEffect
extends Resource

# ============================== Enums ==============================

enum EffectType {
	POISON,
	VULNERABILTY,
	ARMOR,
	PACIFY
}

# ============================== Public variables ==============================

var type: EffectType
var source: Character # Character who is the origin of this effect
var number: int # number of stack
var ticks_left: int # number of tick remaining (for the effects concerned)
