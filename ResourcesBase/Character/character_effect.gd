class_name CharacterEffect
extends Resource

# ============================== Enums ==============================

# TODO Make this CharacterEffect just a PoisonEffect

enum EffectType {
	POISON,
	VULNERABILTY, # Don't need to be like poison, it decreases by x% each second with minimum of y
	ARMOR, # Useless for the moment, armor can be handled easily with just a var in CharacterStats
	PACIFY # Same don't need to be that complicated, can just be like armor
}

# ============================== Public variables ==============================

var type: EffectType
var source: Character # Character who is the origin of this effect
var number: int # number of stack
var ticks_left: int # number of tick remaining (for the effects concerned)
