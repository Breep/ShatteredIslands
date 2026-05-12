class_name TavernEntitySpec
extends EntitySpec

enum TavernRole { 
	MOB,
	HERO_SPAWN,
	ACOLYTE_SPAWN,
}

@export var role: TavernRole = TavernRole.MOB
