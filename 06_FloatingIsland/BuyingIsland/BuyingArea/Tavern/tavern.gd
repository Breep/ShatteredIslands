# Scène 3D de la phase de préparation : pose les props/entités statiques de
# l'encounter, spawn les héros et acolytes du joueur depuis le roaster, et
# reste à l'écoute de Party pour spawn/despawn à la volée pendant la phase
# (effets de cartes type "Recrute mercenaire").
#
# Les héros et acolytes occupent les slots de tavern_formation.{hero,acolyte}_spawn_specs.
# Quand tous les slots d'une catégorie sont pris, les nouvelles entries restent
# dans le roaster mais ne sont pas visualisées (pas de spawn 3D).
class_name Tavern
extends Node3D

@export_group("External Nodes")
@export var _tarven_center: TavernCenter

@export_group("Encounter Spawn Root")
@export var _encounter_root: Node3D

#region ============================== Private variables ==============================
var _party: Party
var _ctx: EntityContext

# Snapshots des spawn specs par catégorie pour la phase active, et assignation
# entry → index dans le snapshot correspondant. erase au remove pour libérer
# le slot. Symétrique entre héros et acolytes.
var _spawn_specs_by_category: Dictionary[Entity.Category, Array] = {}
var _slot_assignment: Dictionary[RoasterEntry, int] = {}
#endregion


#region ============================== Public functions ==============================
# === Old API (à supprimer une fois la nouvelle validée) ===
func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)


func cleanup() -> void:
	_tarven_center.cleanup_table_layouts()
	_disconnect_party_signals()
	_party = null
	_ctx = null
	_spawn_specs_by_category.clear()
	_slot_assignment.clear()


# === New API: populate from a TavernEncounter + Party ===
# Instancie les props/entités statiques du TavernEncounter, puis pose les
# héros et acolytes du joueur depuis le roaster. Garde Party en mémoire et
# s'abonne à ses signaux pour réagir aux ajouts/retraits pendant la phase.
func populate_from_encounter(encounter: TavernEncounter, party: Party) -> void:
	if encounter == null or encounter.tavern_formation == null:
		Verbose.error("Tavern.populate_from_encounter: encounter or tavern_formation is null", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if party == null:
		Verbose.error("Tavern.populate_from_encounter: party is null", Verbose.Category.ENCOUNTER_RUNNER)
		return

	var formation: TavernFormation = encounter.tavern_formation
	var root: Node3D = _get_or_make_encounter_root()
	_clear_children(root)

	for spec: PropSpec in formation.prop_specs:
		spec.spawn_into(root)

	for spec: EntitySpec in formation.entity_specs:
		spec.spawn_into(root)

	_party = party
	_ctx = _build_tavern_ctx()
	_spawn_specs_by_category = {
		Entity.Category.HERO: formation.hero_spawn_specs,
		Entity.Category.ACOLYTE: formation.acolyte_spawn_specs,
	}
	_slot_assignment.clear()

	for entry: RoasterEntry in party.all_entries():
		_place_entry(entry, root)

	_connect_party_signals()
#endregion


#region ============================== Private helpers ==============================
func _get_or_make_encounter_root() -> Node3D:
	if _encounter_root != null:
		return _encounter_root
	_encounter_root = Node3D.new()
	_encounter_root.name = "EncounterRoot"
	add_child(_encounter_root)
	return _encounter_root


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _build_tavern_ctx() -> EntityContext:
	var ctx := EntityContext.new()
	ctx.display_mode = Entity.DisplayMode.BUYING_PHASE
	# runtime_owner_player résolu par entry dans _spawn_entry_at via Party.find_slot_of.
	# pas de spawn_manager : la tavern n'a pas de tick system, fallback
	# add_child d'EntitySpec.spawn_into est utilisé.
	return ctx


# Place une entry sur le premier slot libre de sa catégorie. Si aucun slot
# disponible (ou catégorie non gérée), l'entry reste dans le roaster sans
# spawn 3D — comportement assumé "le surnuméraire reste invisible".
func _place_entry(entry: RoasterEntry, parent: Node3D) -> void:
	if entry == null or entry.desc == null: return
	var category: Entity.Category = entry.desc.default_category
	if not _spawn_specs_by_category.has(category):
		return
	var slot_idx: int = _find_free_slot(category)
	if slot_idx == -1:
		return
	_slot_assignment[entry] = slot_idx
	var spec: SpawnSpec = _spawn_specs_by_category[category][slot_idx]
	var label: String = entry.desc.name if entry.desc.name != "" else "Entity"
	_spawn_entry_at(entry, spec.transform, label, parent)


# Premier index libre dans les spawn specs d'une catégorie. -1 si tous occupés.
# "Libre" = aucune entry actuelle n'est assignée à cet index pour cette catégorie.
func _find_free_slot(category: Entity.Category) -> int:
	var specs: Array = _spawn_specs_by_category.get(category, [])
	var used_indices: Array[int] = []
	for assigned_entry: RoasterEntry in _slot_assignment:
		if assigned_entry.desc != null and assigned_entry.desc.default_category == category:
			used_indices.append(_slot_assignment[assigned_entry])
	for i in specs.size():
		if not used_indices.has(i):
			return i
	return -1


func _spawn_entry_at(entry: RoasterEntry, target_transform: Transform3D, fallback_name: String, parent: Node3D) -> void:
	if entry == null or entry.desc == null or _party == null or _ctx == null: return
	var slot: PlayerState.Slot = _party.find_slot_of(entry)
	var owner: Player = PlayerManager.get_player_by_slot(slot)
	_ctx.runtime_owner_player = owner if owner != null else PlayerManager.get_local_player()
	_ctx.roaster = _party.get_roaster(slot)
	var spec := EntitySpec.new()
	spec.entry = entry
	spec.transform = target_transform
	spec.display_label = fallback_name
	var entity := spec.spawn_into(parent, _ctx) as Entity
	# Lien runtime player -> instance de héros de cette scène.
	if entity != null and entity.is_hero() and _ctx.runtime_owner_player != null:
		_ctx.runtime_owner_player.hero = entity


func _connect_party_signals() -> void:
	if _party == null: return
	if not _party.entry_added.is_connected(_on_party_entry_added):
		_party.entry_added.connect(_on_party_entry_added)
	if not _party.entry_removed.is_connected(_on_party_entry_removed):
		_party.entry_removed.connect(_on_party_entry_removed)


func _disconnect_party_signals() -> void:
	if _party == null: return
	if _party.entry_added.is_connected(_on_party_entry_added):
		_party.entry_added.disconnect(_on_party_entry_added)
	if _party.entry_removed.is_connected(_on_party_entry_removed):
		_party.entry_removed.disconnect(_on_party_entry_removed)
#endregion


#region ============================== Callbacks ==============================
func _on_party_entry_added(entry: RoasterEntry) -> void:
	_place_entry(entry, _get_or_make_encounter_root())


func _on_party_entry_removed(entry: RoasterEntry) -> void:
	if entry == null: return
	_slot_assignment.erase(entry)
	var root: Node3D = _get_or_make_encounter_root()
	for child in root.get_children():
		var entity := child as Entity
		if entity != null and entity.entry == entry:
			entity.queue_free()
			return
#endregion
