# Roaster d'un joueur : sa sous-collection persistante de RoasterEntry
# (héros + acolytes + bâtiments). API métier portée ici (add/remove/lookups).
# Sérialisé via Party.roasters[slot].
class_name Roaster
extends Resource

#region ============================== Signals ==============================
signal entry_added(entry: RoasterEntry)
signal entry_removed(entry: RoasterEntry)
#endregion

#region ============================== Export ==============================
@export var entries: Array[RoasterEntry] = []
#endregion


#region ============================== Public functions ==============================
func add(entry: RoasterEntry) -> RoasterEntry:
	if entry == null:
		Verbose.warn("Roaster.add: entry null, ignoré", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	entries.append(entry)
	entry.ensure_runtime_initialized()
	entry_added.emit(entry)
	if entry.desc != null:
		for companion_desc: EntityDesc in entry.desc.starting_companions:
			add(RoasterEntry.from_desc(companion_desc))
	return entry


func remove(entry: RoasterEntry) -> bool:
	var idx: int = entries.find(entry)
	if idx == -1:
		return false
	entries.remove_at(idx)
	entry_removed.emit(entry)
	return true


func get_hero() -> RoasterEntry:
	return get_first_of_category(Entity.Category.HERO)


func get_first_of_category(category: Entity.Category) -> RoasterEntry:
	for entry: RoasterEntry in entries:
		if entry == null or entry.desc == null:
			continue
		if entry.desc.default_category == category:
			return entry
	return null


func get_by_category(category: Entity.Category) -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	for entry: RoasterEntry in entries:
		if entry == null or entry.desc == null:
			continue
		if entry.desc.default_category == category:
			result.append(entry)
	return result


func has(entry: RoasterEntry) -> bool:
	return entries.has(entry)


func size() -> int:
	return entries.size()


# Entries posées par une source identifiée (ex. nom d'une carte). Ordre stable
# = ordre d'insertion. Vide si aucune entry n'a ce source_id.
func get_by_source(source: StringName) -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	for entry: RoasterEntry in entries:
		if entry != null and entry.source_id == source:
			result.append(entry)
	return result


# Retire toutes les entries posées par une source. Retourne le nombre retiré.
# Chaque retrait émet entry_removed (donc Party propagera la mise à jour de
# formation et la Tavern despawnera les Entities visuelles).
func remove_by_source(source: StringName) -> int:
	var to_remove: Array[RoasterEntry] = get_by_source(source)
	for entry: RoasterEntry in to_remove:
		remove(entry)
	return to_remove.size()


# Entries portant un tag donné. Tags ne sont pas exclusifs : une entry peut
# en avoir plusieurs et matcher sur n'importe lequel.
func get_by_tag(tag: StringName) -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	for entry: RoasterEntry in entries:
		if entry != null and entry.source_tags.has(tag):
			result.append(entry)
	return result
#endregion
