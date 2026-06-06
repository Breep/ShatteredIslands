# Roaster d'un joueur : 1 héros + N acolytes + M buildings. C'est tout.
# Sérialisé via Party.roasters[slot]. API typée pour qu'aucun call site n'ait
# besoin de filtrer par catégorie.
class_name Roaster
extends Resource

#region ============================== Signals ==============================
signal entry_added(entry: RoasterEntry)
signal entry_removed(entry: RoasterEntry)
#endregion

#region ============================== Export ==============================
@export var hero: RoasterEntry
@export var acolytes: Array[RoasterEntry] = []
@export var buildings: Array[RoasterEntry] = []
#endregion


#region ============================== Public functions ==============================
# Pose / remplace le héros du roaster. Cascade les starting_companions de la
# desc vers les bons slots (acolyte / building) selon leur default_category.
func set_hero(desc: EntityDesc) -> RoasterEntry:
	if desc == null:
		Verbose.warn("Roaster.set_hero: desc null, ignoré", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	var entry := RoasterEntry.from_desc(desc)
	hero = entry
	entry.ensure_runtime_initialized()
	entry_added.emit(entry)
	for companion_desc: EntityDesc in desc.starting_companions:
		_add_companion(companion_desc)
	return entry


func add_acolyte(desc: EntityDesc, source: StringName = &"") -> RoasterEntry:
	if desc == null:
		Verbose.warn("Roaster.add_acolyte: desc null, ignoré", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	var entry := RoasterEntry.from_desc(desc)
	entry.source_id = source
	acolytes.append(entry)
	entry.ensure_runtime_initialized()
	entry_added.emit(entry)
	return entry


func add_building(desc: EntityDesc, source: StringName = &"") -> RoasterEntry:
	if desc == null:
		Verbose.warn("Roaster.add_building: desc null, ignoré", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	var entry := RoasterEntry.from_desc(desc)
	entry.source_id = source
	buildings.append(entry)
	entry.ensure_runtime_initialized()
	entry_added.emit(entry)
	return entry


# Retire une entry sans avoir à connaître son type (cherche dans acolytes puis
# buildings). Le héros n'est pas retirable ici — utiliser set_hero pour changer.
# Retourne true si une entry a été retirée.
func remove(entry: RoasterEntry) -> bool:
	if acolytes.has(entry):
		acolytes.erase(entry)
		entry_removed.emit(entry)
		return true
	if buildings.has(entry):
		buildings.erase(entry)
		entry_removed.emit(entry)
		return true
	return false


# Toutes les entries du roaster (hero + acolytes + buildings). Pour itération
# externe ou affichage UI. L'ordre est : hero, acolytes, buildings.
func all_entries() -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	if hero != null:
		result.append(hero)
	result.append_array(acolytes)
	result.append_array(buildings)
	return result


func has(entry: RoasterEntry) -> bool:
	if hero == entry:
		return true
	return acolytes.has(entry) or buildings.has(entry)


func size() -> int:
	var count: int = 0
	if hero != null:
		count += 1
	count += acolytes.size()
	count += buildings.size()
	return count


# Source tracking : utilisé par les cartes qui posent/retirent des entries en
# bloc (ex: HireAcolyte). À déplacer côté carte plus tard.
func get_by_source(source: StringName) -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	for entry: RoasterEntry in acolytes:
		if entry != null and entry.source_id == source:
			result.append(entry)
	for entry: RoasterEntry in buildings:
		if entry != null and entry.source_id == source:
			result.append(entry)
	return result


func remove_by_source(source: StringName) -> int:
	var to_remove: Array[RoasterEntry] = get_by_source(source)
	for entry: RoasterEntry in to_remove:
		remove(entry)
	return to_remove.size()
#endregion


#region ============================== Private functions ==============================
# Aiguillage d'un starting_companion vers le bon slot selon default_category.
func _add_companion(companion_desc: EntityDesc) -> void:
	if companion_desc == null:
		return
	match companion_desc.default_category:
		Entity.Category.ACOLYTE:
			add_acolyte(companion_desc)
		Entity.Category.BUILDING:
			add_building(companion_desc)
		_:
			Verbose.warn("Roaster: starting_companion de catégorie inattendue [" + str(companion_desc.default_category) + "] sur " + companion_desc.name, Verbose.Category.ENCOUNTER_RUNNER)
#endregion
