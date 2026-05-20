# DEPRECATED — remplacé par MobSpec (Concrete/).
# Conservé pour permettre le chargement des .tres legacy. Sera supprimé après
# migration de toutes les ressources via les builders (Load → Save).
@tool
class_name TavernEntitySpec
extends EntitySpec

enum TavernRole {
	MOB,
}

@export var role: TavernRole = TavernRole.MOB
