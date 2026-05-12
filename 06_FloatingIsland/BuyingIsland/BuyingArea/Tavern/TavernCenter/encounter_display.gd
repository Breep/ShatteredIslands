class_name EncounterDisplay
extends Node3D

# ============================== Export (Local) ==============================

@export_group("Slots de position")
# Positions où sont placés les héros joueurs (Node3D vides dans la scène).
@export var _player_seats: Array[Node3D]
# Positions où sont placés les masters (ennemis principaux).
@export var _master_seats: Array[Node3D]
# Positions où sont placés les slaves (ennemis secondaires, debout derrière).
@export var _slave_spots: Array[Node3D]

@export_group("Debug")
# Si true, les MeshInstance3D enfants des slots sont masqués au démarrage du jeu.
# Permet d'avoir des marqueurs visuels (petits cubes/sphères) sous chaque seat
# pour les positionner dans l'éditeur, sans qu'ils apparaissent en jeu.
@export var _hide_slot_debug_meshes_at_runtime: bool = true

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
	if _hide_slot_debug_meshes_at_runtime:
		_hide_debug_meshes_in_slots()
	if _editor_preview != null:
		_editor_preview.queue_free()

# ============================== Public functions ==============================

func display(encounter: TavernEncounter) -> void:
	_place(encounter.players, _player_seats, "player")
	_place(encounter.masters, _master_seats, "master")
	_place(encounter.slaves, _slave_spots, "slave")


func cleanup() -> void:
	for child in _entities_node.get_children():
		child.queue_free()


# ============================== Private functions ==============================

# Place les `entities` dans les `slots` en les centrant.
# Si N entités à placer dans M slots (N <= M), on saute (M - N) / 2 slots
# au début pour centrer. Ex: 1 entité dans 4 slots → entité va dans slot d'indice 1.
func _place(entities: Array, slots: Array[Node3D], role: String) -> void:
	if entities.is_empty():
		return
	if entities.size() > slots.size():
		push_warning("EncounterDisplay: %d %s à placer mais seulement %d slots disponibles" \
			% [entities.size(), role, slots.size()])
		return

	var offset: int = (slots.size() - entities.size()) / 2
	for i in entities.size():
		var entity: Node3D = entities[i]
		var slot: Node3D = slots[offset + i]
		if entity.is_inside_tree():
			push_warning("EncounterDisplay: %s '%s' déjà dans l'arbre, placement ignoré" \
				% [role, entity.name])
			continue
		_entities_node.add_child(entity)
		entity.global_position = slot.global_position
		entity.global_rotation = slot.global_rotation


# Parcourt tous les slots et masque les MeshInstance3D enfants éventuels.
# Utile pour cacher les marqueurs de debug ajoutés à l'édition.
func _hide_debug_meshes_in_slots() -> void:
	var all_slots: Array[Node3D] = []
	all_slots.append_array(_player_seats)
	all_slots.append_array(_master_seats)
	all_slots.append_array(_slave_spots)
	for slot in all_slots:
		for child in slot.get_children():
			if child is MeshInstance3D:
				child.visible = false
