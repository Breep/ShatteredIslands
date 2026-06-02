# Une Party = un groupe de joueurs persistant à travers les confrontations.
# Détient les joueurs (état de run sauvegardable), le roaster (inventaire
# canonique des entités du joueur avec leurs méta-données : niveau, hand,
# mémoire) et la formation actuelle (positions des entités sur le board côté
# joueur). C'est l'état "vivant" injecté dans chaque Encounter.
#
# Resource : sérialisable en .tres, prête à être embarquée dans le RunContext
# pour la save inter-confrontation.
class_name Party
extends Resource

#region ============================== Signals ==============================
signal roaster_entry_added(entry: RoasterEntry)
signal roaster_entry_removed(entry: RoasterEntry)
#endregion

#region ============================== Export ==============================
@export var players: Array[PlayerState]
@export var formation: FightingFormation
@export var roaster: Array[RoasterEntry]
## Coffre partagé par toute l'équipe : stockage de cartes hors-héros.
@export var chest: Deck = Deck.new()
#endregion


#region ============================== Public functions ==============================
func add_to_roaster(entry: RoasterEntry) -> RoasterEntry:
	if entry == null:
		Verbose.warn("Party.add_to_roaster: entry null, ignoré", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	roaster.append(entry)
	roaster_entry_added.emit(entry)
	if entry.desc != null:
		for companion_desc: EntityDesc in entry.desc.starting_companions:
			add_to_roaster(RoasterEntry.from_desc(companion_desc))
	return entry


func remove_from_roaster(entry: RoasterEntry) -> bool:
	var idx: int = roaster.find(entry)
	if idx == -1:
		return false
	roaster.remove_at(idx)
	roaster_entry_removed.emit(entry)
	return true


# Première entrée du roaster d'une catégorie donnée. Utilisé par Player pour
# résoudre "mon entrée" en solo (futur multi : mapping via player.team / id).
func get_first_entry_of_category(category: Entity.Category) -> RoasterEntry:
	for entry: RoasterEntry in roaster:
		if entry == null or entry.desc == null:
			continue
		if entry.desc.default_category == category:
			return entry
	return null
#endregion
