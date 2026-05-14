# DEPRECATED — remplacé par HeroSpawnSpec / AcolyteSpawnSpec (Concrete/).
# Conservé pour permettre le chargement des .tres legacy. Sera supprimé après
# migration de toutes les ressources via les builders (Load → Save).
class_name SpawnPointSpec
extends SpawnSpec

enum SpawnRole {
	HERO,
	ACOLYTE,
}

@export var role: SpawnRole = SpawnRole.HERO
