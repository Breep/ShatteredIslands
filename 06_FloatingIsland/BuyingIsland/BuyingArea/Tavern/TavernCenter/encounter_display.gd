class_name EncounterDisplay
extends Node3D

# ============================== Export (Local) ==============================

@export_group("Slots de position")
# Positions où sont placés les héros joueurs (Node3D ou TavernSlot dans la scène).
@export var _player_seats: Array[Node3D]
# Positions où sont placés les masters (ennemis principaux).
@export var _master_seats: Array[Node3D]
# Positions où sont placés les slaves (ennemis secondaires, debout derrière).
@export var _slave_spots: Array[Node3D]

@export_group("Debug")
# Si true, les MeshInstance3D enfants des slots sont masqués au démarrage du jeu.
# Permet d'avoir des marqueurs visuels (petits cubes/sphères) sous chaque seat
# pour les positionner dans l'éditeur, sans qu'ils apparaissent en jeu.

# Nœud facultatif servant uniquement d'aperçu visuel à l'édition (par exemple
# une instance de tavern.tscn pour visualiser l'environnement autour du
# TavernCenter pendant qu'on positionne les seats). Il est automatiquement
# supprimé (queue_free) au démarrage du jeu — il n'a aucun coût en runtime.
@export var _editor_preview: Node3D

# ============================== Local nodes ==============================

# Container runtime : toutes les entités spawn sont parentées ici pour faciliter le cleanup.
@onready var _entities_node: Node3D = %Entities

# ============================== Node base functions ==============================

func _ready() -> void:
	if _editor_preview != null:
		_editor_preview.queue_free()

# ============================== Public functions ==============================

# Affiche un encounter en deux passes :
#   1. Placements explicites (encounter.fixed_placements) : ciblent un slot par son slot_id
#   2. Auto-placement (encounter.players/masters/slaves) : centrage séquentiel sur les slots restants
# Une entité présente dans fixed_placements ET dans un pool est placée d'abord via fixed,
# puis ignorée par l'auto. Si le slot ciblé est introuvable, l'entité retombe sur l'auto.
func display(encounter: TavernEncounter) -> void:
	var slot_map: Dictionary[StringName, Node3D] = _build_slot_map()
	var used_slots: Dictionary[Node3D, bool] = {}
	var placed_entities: Dictionary[Node3D, bool] = {}

	# === Passe 1 : placements explicites ===
	for entity: Node3D in encounter.fixed_placements:
		var slot_id: StringName = encounter.fixed_placements[entity]
		if not slot_map.has(slot_id):
			push_warning("EncounterDisplay: slot_id '%s' introuvable, fallback auto-placement pour '%s'" \
				% [slot_id, entity.name])
			continue
		var slot: Node3D = slot_map[slot_id]
		if used_slots.has(slot):
			push_warning("EncounterDisplay: slot '%s' déjà occupé, fallback auto-placement pour '%s'" \
				% [slot_id, entity.name])
			continue
		if _place_entity_at(entity, slot):
			used_slots[slot] = true
			placed_entities[entity] = true

	# === Passe 2 : auto-placement sur les slots/entités restants ===
	_auto_place(encounter.players, _player_seats, used_slots, placed_entities, "player")
	_auto_place(encounter.masters, _master_seats, used_slots, placed_entities, "master")
	_auto_place(encounter.slaves, _slave_spots, used_slots, placed_entities, "slave")


func cleanup() -> void:
	for child in _entities_node.get_children():
		child.queue_free()


# ============================== Private functions ==============================

# Construit le mapping slot_id → Node3D en scannant les 3 arrays de slots.
# Seuls les Node3D ayant le script TavernSlot et un slot_id non vide sont indexés.
func _build_slot_map() -> Dictionary[StringName, Node3D]:
	var map: Dictionary[StringName, Node3D] = {}
	var all_slots: Array[Node3D] = []
	all_slots.append_array(_player_seats)
	all_slots.append_array(_master_seats)
	all_slots.append_array(_slave_spots)
	for slot in all_slots:
		if slot is TavernSlot:
			var ts: TavernSlot = slot
			if ts.slot_id == &"":
				continue
			if map.has(ts.slot_id):
				push_warning("EncounterDisplay: slot_id '%s' dupliqué dans la scène" % ts.slot_id)
			map[ts.slot_id] = ts
	return map


# Place les entités d'un pool dans ses slots, en filtrant celles déjà placées
# (par fixed) et les slots déjà occupés. Centre sur les slots restants.
func _auto_place(entities: Array, slots: Array[Node3D],
		used: Dictionary[Node3D, bool], placed: Dictionary[Node3D, bool], role: String) -> void:
	var remaining_entities: Array[Node3D] = []
	for entity: Node3D in entities:
		if not placed.has(entity):
			remaining_entities.append(entity)

	if remaining_entities.is_empty():
		return

	var available_slots: Array[Node3D] = []
	for slot in slots:
		if not used.has(slot):
			available_slots.append(slot)

	if remaining_entities.size() > available_slots.size():
		push_warning("EncounterDisplay: %d %s à placer mais seulement %d slots disponibles" \
			% [remaining_entities.size(), role, available_slots.size()])
		return

	var offset: int = (available_slots.size() - remaining_entities.size()) / 2
	for i in remaining_entities.size():
		_place_entity_at(remaining_entities[i], available_slots[offset + i])


# Reparente l'entité au container et copie position+rotation du slot.
# Retourne true si placée, false si l'entité était déjà dans l'arbre.
func _place_entity_at(entity: Node3D, slot: Node3D) -> bool:
	if entity.is_inside_tree():
		push_warning("EncounterDisplay: '%s' déjà dans l'arbre, placement ignoré" % entity.name)
		return false
	_entities_node.add_child(entity)
	entity.global_position = slot.global_position
	entity.global_rotation = slot.global_rotation
	return true
