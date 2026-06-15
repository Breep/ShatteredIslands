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
# 1 EntitySpec, posé par défaut dans la zone de spawn joueur). Elle ré-émet
# entry_added / entry_removed pour les consommateurs externes (Tavern principalement).
class_name Party
extends Resource

#region ============================== Signals ==============================
signal entry_added(entry: RoasterEntry)
signal entry_removed(entry: RoasterEntry)
#endregion

#region ============================== Constants ==============================
# Centre de la zone de spawn côté joueur. Les entries ajoutées y sont posées
# par défaut, puis réparties autour si la place est déjà prise.
const SPAWN_CENTER := Vector3(6, 0, 0)
# Pas de la grille de placement automatique (distance entre deux unités).
const SPAWN_SPACING := 2.0
# Garde-fou sur la recherche en anneaux concentriques (évite une boucle infinie
# si tous les emplacements proches sont saturés).
const MAX_SPAWN_RINGS := 6
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


# Auto-sync formation : crée un EntitySpec pour chaque entry ajoutée à un
# roaster, posé au centre de la zone de spawn joueur (ou sur l'emplacement libre
# le plus proche si le centre est déjà occupé). Le joueur peut le repositionner
# ensuite en phase de placement.
func _on_roaster_entry_added(entry: RoasterEntry) -> void:
	if entry == null:
		return
	if find_spec_by_entry(entry) != null:
		return  # garde-fou : 1 entry = 1 spec
	var spec := EntitySpec.new()
	spec.entry = entry
	spec.desc = entry.desc
	spec.transform = Transform3D(Basis.from_euler(Vector3(0, PI / 2, 0)), _find_free_spawn_position())
	formation.entity_specs.append(spec)
	entry_added.emit(entry)


func _on_roaster_entry_removed(entry: RoasterEntry) -> void:
	if entry == null:
		return
	var spec: EntitySpec = find_spec_by_entry(entry)
	if spec != null:
		formation.entity_specs.erase(spec)
	entry_removed.emit(entry)


# Cherche une position libre en partant du centre de la zone de spawn, puis sur
# des anneaux carrés concentriques de plus en plus larges. Retourne le centre en
# dernier recours si tout est saturé (les specs s'empilent alors).
func _find_free_spawn_position() -> Vector3:
	if _is_position_free(SPAWN_CENTER):
		return SPAWN_CENTER
	for ring: int in range(1, MAX_SPAWN_RINGS + 1):
		for offset: Vector3 in _ring_offsets(ring):
			var candidate: Vector3 = SPAWN_CENTER + offset
			if _is_position_free(candidate):
				return candidate
	return SPAWN_CENTER


# Offsets (en unités monde) du périmètre d'un anneau carré de rayon `ring`
# cellules autour du centre, espacés de SPAWN_SPACING.
func _ring_offsets(ring: int) -> Array[Vector3]:
	var offsets: Array[Vector3] = []
	for x: int in range(-ring, ring + 1):
		for z: int in range(-ring, ring + 1):
			if maxi(absi(x), absi(z)) != ring:
				continue
			offsets.append(Vector3(x, 0, z) * SPAWN_SPACING)
	return offsets


# Vrai si aucun EntitySpec déjà placé n'occupe (à une demi-cellule près) cette
# position.
func _is_position_free(position: Vector3) -> bool:
	for spec: EntitySpec in formation.entity_specs:
		if spec.transform.origin.distance_to(position) < SPAWN_SPACING * 0.5:
			return false
	return true
#endregion
