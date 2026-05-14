# DEPRECATED — remplacé par HeroSpec/AcolyteSpec/AntagonistSpec/BuildingSpec (Concrete/).
# Conservé pour permettre le chargement des .tres legacy. Sera supprimé après
# migration de toutes les ressources via les builders (Load → Save).
class_name FightingEntitySpec
extends EntitySpec

enum FightingRole {
	ANTAGONIST,
	HERO,
	ACOLYTE,
	BUILDING,
}

@export var role: FightingRole
