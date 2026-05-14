class_name FightingEntitySpec
extends EntitySpec

enum FightingRole {
	ANTAGONIST,
	HERO,
	ACOLYTE,
	BUILDING,
}

@export var role: FightingRole
