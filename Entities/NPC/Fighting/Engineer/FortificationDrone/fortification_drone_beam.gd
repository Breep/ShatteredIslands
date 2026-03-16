class_name FortificationDroneBeam
extends Node3D

@onready var _mesh: MeshInstance3D = %Mesh

func update_beam(from_pos: Vector3, to_pos: Vector3) -> void:
	if _mesh == null: return
	global_position = (from_pos + to_pos) / 2.0
	if not from_pos.is_equal_approx(to_pos):
		look_at(to_pos, Vector3.UP)
	var distance = from_pos.distance_to(to_pos)
	_mesh.scale.y = distance
