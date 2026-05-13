# Spec describing an entity present in a tavern formation (mobs, NPCs, ...).
# Spawn placeholders (hero / acolyte) are NOT TavernEntitySpec — see SpawnPointSpec.
class_name TavernEntitySpec
extends EntitySpec

enum TavernRole {
	MOB,
}

@export var role: TavernRole = TavernRole.MOB
