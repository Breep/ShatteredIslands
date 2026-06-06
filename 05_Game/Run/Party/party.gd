# Une Party = un groupe de joueurs persistant à travers les confrontations.
# Détient les joueurs (état de run sauvegardable), un Roaster par slot
# (inventaire de chaque joueur : héros, acolytes, bâtiments), la formation
# côté joueur (UNIQUE pour tout le groupe, agrège tous les roasters) et le
# coffre partagé. État "vivant" injecté dans chaque Encounter.
#
# Resource : sérialisable en .tres pour la save inter-confrontation.
#
# Pivot des signaux : Party s'abonne aux roasters qu'elle contient et
# maintient automatiquement formation.entity_specs en sync (1 entry =
# 1 EntitySpec, transform IDENTITY par défaut). Elle ré-émet entry_added /
# entry_removed pour les consommateurs externes (Tavern principalement).
class_name Party
extends Resource

#region ============================== Signals ==============================
signal entry_added(entry: RoasterEntry)
signal entry_removed(entry: RoasterEntry)
#endregion

#region ============================== Export ==============================
@export var players: Array[PlayerState]
@export var formation: FightingFormation
@export var roasters: Dictionary[PlayerState.Slot, Roaster] = {}
## Coffre partagé par toute l'équipe : stockage de cartes hors-héros.
@export var chest: Deck = Deck.new()
#endregion


#region ============================== Public functions ==============================
func _init() -> void:
	if formation == null:
		formation = FightingFormation.new()


# Roaster d'un slot. null si aucun roaster posé pour ce slot.
func get_roaster(slot: PlayerState.Slot) -> Roaster:
	return roasters.get(slot)


# Idem, mais crée le Roaster si absent. À utiliser quand on pose l'ownership
# (ajout d'un héros au lock, etc.). Connecte automatiquement les signaux du
# nouveau Roaster pour que la formation reste en sync.
func get_or_create_roaster(slot: PlayerState.Slot) -> Roaster:
	if not roasters.has(slot):
		var roaster := Roaster.new()
		roasters[slot] = roaster
		_connect_roaster(roaster)
	return roasters[slot]


# Slot du joueur propriétaire d'une entry. NONE si l'entry n'appartient à
# aucun roaster connu.
func find_slot_of(entry: RoasterEntry) -> PlayerState.Slot:
	for slot: PlayerState.Slot in roasters:
		if roasters[slot].has(entry):
			return slot
	return PlayerState.Slot.NONE


# EntitySpec correspondant à une entry dans la formation. null si absent.
# Invariant : 1 entry = au plus 1 spec.
func find_spec_by_entry(entry: RoasterEntry) -> EntitySpec:
	if formation == null:
		return null
	for spec: EntitySpec in formation.entity_specs:
		if spec.entry == entry:
			return spec
	return null


# Itération plate sur toutes les entries de tous les roasters confondus.
# Pratique pour les passes globales (attach scenes, init runtime data...).
func all_entries() -> Array[RoasterEntry]:
	var result: Array[RoasterEntry] = []
	for roaster: Roaster in roasters.values():
		result.append_array(roaster.all_entries())
	return result
#endregion


#region ============================== Private functions ==============================
func _connect_roaster(roaster: Roaster) -> void:
	if not roaster.entry_added.is_connected(_on_roaster_entry_added):
		roaster.entry_added.connect(_on_roaster_entry_added)
	if not roaster.entry_removed.is_connected(_on_roaster_entry_removed):
		roaster.entry_removed.connect(_on_roaster_entry_removed)


# Auto-sync formation : crée un EntitySpec (transform IDENTITY = (0,0,0)) pour
# chaque entry ajoutée à un roaster. La position propre sera posée plus tard
# par le joueur en phase de placement.
func _on_roaster_entry_added(entry: RoasterEntry) -> void:
	if entry == null:
		return
	if find_spec_by_entry(entry) != null:
		return  # garde-fou : 1 entry = 1 spec
	var spec := EntitySpec.new()
	spec.entry = entry
	spec.desc = entry.desc
	spec.transform = Transform3D.IDENTITY
	formation.entity_specs.append(spec)
	entry_added.emit(entry)


func _on_roaster_entry_removed(entry: RoasterEntry) -> void:
	if entry == null:
		return
	var spec: EntitySpec = find_spec_by_entry(entry)
	if spec != null:
		formation.entity_specs.erase(spec)
	entry_removed.emit(entry)
#endregion
