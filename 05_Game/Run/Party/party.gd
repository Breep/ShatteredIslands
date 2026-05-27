# Une Party = un groupe de joueurs persistant à travers les confrontations.
# Détient les joueurs (état de run sauvegardable), le roaster (inventaire
# canonique des entités du joueur avec leurs méta-données : niveau, deck,
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


# Helpers : extraire les specs par rôle depuis formation.entity_specs.
# Utilisés par les Runners pour alimenter la taverne ET le combat — les specs
# portent la donnée canonique (deck, level, etc. sur HeroSpec) que les deux
# phases ont besoin d'injecter sur l'instance Hero éphémère.
func get_hero_specs() -> Array[HeroSpec]:
	var result: Array[HeroSpec] = []
	if formation == null: return result
	for spec: EntitySpec in formation.entity_specs:
		if spec is HeroSpec:
			result.append(spec)
	return result


func get_acolyte_specs() -> Array[AcolyteSpec]:
	var result: Array[AcolyteSpec] = []
	if formation == null: return result
	for spec: EntitySpec in formation.entity_specs:
		if spec is AcolyteSpec:
			result.append(spec)
	return result
#endregion
