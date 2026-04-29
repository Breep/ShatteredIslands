class_name TavernEncounter
extends RefCounted

# Décrit ce qui doit être affiché dans le TavernCenter pour un round de coop/mono.
#
# Mode auto (par défaut) : ajouter les entités dans players/masters/slaves —
# elles sont placées automatiquement (centré + séquentiel) dans les seats
# correspondant à leur rôle.
#
# Mode override scénaristique : pour pinner une entité à un slot spécifique,
# l'ajouter dans son pool de rôle ET ajouter une entrée dans fixed_placements.
# L'engine essaiera le slot ciblé en premier, et fallback sur l'auto-placement
# si le slot est introuvable (warning console).

# === Auto-placement ===
var players: Array[Hero]
var masters: Array[Entity]
var slaves: Array[Entity]

# === Override : entité → slot_id (cf TavernSlots) ===
# Une entité peut être pinnée à n'importe quel slot des 3 catégories.
# Si la slot_id est introuvable au runtime, l'entité retombe sur l'auto-placement.
var fixed_placements: Dictionary[Node3D, StringName] = {}
