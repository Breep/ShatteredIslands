# Marker spec describing a spawn location (Transform only, no entity attached).
# Used to record placeholder Node3D positions where heroes / acolytes will spawn at runtime.
class_name SpawnPointSpec
extends SpawnSpec

enum SpawnRole {
	HERO,
	ACOLYTE,
}

@export var role: SpawnRole = SpawnRole.HERO
