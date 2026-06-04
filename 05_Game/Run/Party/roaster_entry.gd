# Une entrée du roaster du joueur : référence à une EntityDesc + méta-données
# persistantes (niveau, hand, mémoire). Source de vérité pour l'inventaire
# côté joueur ; les EntitySpec en formation pointent vers leur RoasterEntry.
# Le slot propriétaire est porté par le Roaster qui contient cette entry
# (cf. Party.roasters[slot]) — pas dupliqué ici.
class_name RoasterEntry
extends Resource

@export var desc: EntityDesc
@export_range(1, 20) var level: int = 1
@export var xp: int = 0
@export var hand: Hand
@export var data_memory: NestedRegistry


static func from_desc(d: EntityDesc) -> RoasterEntry:
	var entry := RoasterEntry.new()
	entry.desc = d
	return entry
