# Une entrée du roaster du joueur : référence à une EntityDesc + méta-données
# persistantes (niveau, hand, mémoire). Source de vérité pour l'inventaire
# côté joueur ; les EntitySpec en formation pointent vers leur RoasterEntry.
# owner_slot rattache l'entry à un joueur (slot stable inter-run).
class_name RoasterEntry
extends Resource

@export var desc: EntityDesc
@export_range(1, 20) var level: int = 1
@export var xp: int = 0
@export var hand: Hand
@export var data_memory: NestedRegistry
# Slot du joueur propriétaire. NONE = non possédé (ennemi, partagé).
@export var owner_slot: PlayerState.Slot = PlayerState.Slot.NONE


static func from_desc(d: EntityDesc, owner := PlayerState.Slot.NONE) -> RoasterEntry:
	var entry := RoasterEntry.new()
	entry.desc = d
	entry.owner_slot = owner
	return entry
