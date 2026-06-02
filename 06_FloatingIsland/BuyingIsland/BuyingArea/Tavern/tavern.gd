class_name Tavern
extends Node3D

@export_group("External Nodes")
@export var _tarven_center: TavernCenter

@export_group("Encounter Spawn Root")
@export var _encounter_root: Node3D


# === Old API (à supprimer une fois la nouvelle validée) ===
func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)


func cleanup() -> void:
	_tarven_center.cleanup_table_layouts()


# === New API: populate from a TavernEncounter ===
# Instancie les props/entités statiques du TavernEncounter, puis pose le héros
# et les acolytes du joueur à partir des RoasterEntries reçues. Les positions
# proviennent des spawn_specs de la tavern_formation — la tavern n'utilise pas
# la position stockée sur l'entry (encounter-driven layout).
func populate_from_encounter(encounter: TavernEncounter, hero_entries: Array[RoasterEntry], acolyte_entries: Array[RoasterEntry]) -> void:
	if encounter == null or encounter.tavern_formation == null:
		Verbose.error("Tavern.populate_from_encounter: encounter or tavern_formation is null", Verbose.Category.ENCOUNTER_RUNNER)
		return

	var formation: TavernFormation = encounter.tavern_formation
	var root: Node3D = _get_or_make_encounter_root()
	_clear_children(root)

	for spec: PropSpec in formation.prop_specs:
		spec.spawn_into(root)

	for spec: EntitySpec in formation.entity_specs:
		spec.spawn_into(root)

	var ctx: EntityContext = _build_tavern_ctx()

	var placed_heroes: int = mini(hero_entries.size(), formation.hero_spawn_specs.size())
	for i in placed_heroes:
		_spawn_entry_at(hero_entries[i], formation.hero_spawn_specs[i].transform, "Hero_" + str(i), root, ctx)

	var placed_acolytes: int = mini(acolyte_entries.size(), formation.acolyte_spawn_specs.size())
	for i in placed_acolytes:
		_spawn_entry_at(acolyte_entries[i], formation.acolyte_spawn_specs[i].transform, "Acolyte_" + str(i), root, ctx)


# === Private helpers ===
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
	# runtime_owner_player résolu par entry dans _spawn_entry_at (owner_slot).
	# pas de spawn_manager : la tavern n'a pas de tick system, fallback
	# add_child d'EntitySpec.spawn_into est utilisé.
	return ctx


func _spawn_entry_at(entry: RoasterEntry, target_transform: Transform3D, fallback_name: String, parent: Node3D, ctx: EntityContext) -> void:
	if entry == null or entry.desc == null: return
	var owner: Player = PlayerManager.get_player_by_slot(entry.owner_slot)
	ctx.runtime_owner_player = owner if owner != null else PlayerManager.get_local_player()
	var spec := EntitySpec.new()
	spec.desc = entry.desc
	spec.entry = entry
	spec.transform = target_transform
	spec.display_label = fallback_name
	spec.spawn_into(parent, ctx)
