class_name FieldGeneratorBeam
extends Node3D

@onready var _mesh: MeshInstance3D = %Mesh

func _ready() -> void:
	if _mesh:
		# Initial setup if needed, e.g. material override
		pass

func update_beam(from_pos: Vector3, to_pos: Vector3) -> void:
	if _mesh == null: return
	
	# Position at midpoint
	global_position = (from_pos + to_pos) / 2.0
	
	# Look at target
	if not from_pos.is_equal_approx(to_pos):
		look_at(to_pos, Vector3.UP)
	
	# Rotate to align cylinder with Z-axis (Godot cylinders are Y-aligned by default, looking usually uses -Z)
	# But here we look_at, so -Z points to target.
	# Cylinder is Y-up. We need to rotate X by -90 to make Y point along Z.
	_mesh.rotation_degrees.x = -90
	
	# Scale height (Y after rotation, or Z if we scaled along local Z)
	# Cylinder height is Y.
	var distance = from_pos.distance_to(to_pos)
	_mesh.scale.y = distance
	
	# Optional: Pulsating thickness or texture scroll can be added here
