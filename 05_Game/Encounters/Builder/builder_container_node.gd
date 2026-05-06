@tool
class_name EditorContainerNode
extends Node3D

@export var role: EntitySpec.Role = EntitySpec.Role.ACOLYTE
@export var snap_to_hex: bool = true
@export var arena_layout: ArenaLayout
@export var camp: int = 0  # 0 = joueur, 1 = ennemi

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint(): return
	if not snap_to_hex or arena_layout == null: return
	
	for child in get_children():
		if child is Entity:
			_snap_entity(child)


func _snap_entity(entity: Entity) -> void:
	var hex = HexUtils.world_to_axial(
		entity.global_position, 
		arena_layout.hex_size,
		HexUtils.Orientation.POINTY_TOP,
		arena_layout.world_origin
	)
	var snapped_pos = HexUtils.axial_to_world(
		hex, 
		arena_layout.hex_size,
		HexUtils.Orientation.POINTY_TOP,
		arena_layout.world_origin
	)
	snapped_pos.y = entity.global_position.y  # garde la hauteur libre
	entity.global_position = snapped_pos
	
	# Tinte si invalide
	var is_valid = arena_layout.is_valid_hex(hex, camp)
	_set_entity_validity_tint(entity, is_valid)


func _set_entity_validity_tint(entity: Entity, valid: bool) -> void:
	# Cherche un MeshInstance3D dans l'entité, override material si invalide
	if not entity.has_node("ValidityIndicator"):
		return  # à toi de décider ton mode visuel : decal rouge, contour, etc.
	entity.get_node("ValidityIndicator").visible = not valid
