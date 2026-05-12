class_name EntitySpec
extends SpawnSpec

enum Role {
	ANTAGONIST = 0,
	ACOLYTE = 1,
	BUILDING = 2,
	HERO = 3,
	NPC = 4,
}

@export var role: Role
@export var stats_override: EntityStats = null
