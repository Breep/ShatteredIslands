# Une entrée du roaster du joueur : référence à une EntityDesc + méta-données
# persistantes (niveau, deck, mémoire). Source de vérité pour l'inventaire
# côté joueur ; les EntitySpec en formation pointent vers leur RoasterEntry.
class_name RoasterEntry
extends Resource

@export var desc: EntityDesc
@export_range(1, 20) var level: int = 1
@export var xp: int = 0
@export var deck: Hand
@export var data_memory: NestedRegistry


static func from_desc(d: EntityDesc) -> RoasterEntry:
	var entry := RoasterEntry.new()
	entry.desc = d
	return entry
