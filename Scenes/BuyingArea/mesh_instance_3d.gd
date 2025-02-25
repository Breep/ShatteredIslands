class_name DebugMesh
extends MeshInstance3D

var immediate_mesh = ImmediateMesh.new()

func _ready():
	mesh = immediate_mesh  # Attach the ImmediateMesh to this node

func draw_line(from_point: Vector3, to_point: Vector3, color: Color = Color(1, 1, 1)):
	immediate_mesh.clear_surfaces()  # Clear previous lines
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	immediate_mesh.surface_set_color(color)
	immediate_mesh.surface_add_vertex(from_point)  # Start point

	immediate_mesh.surface_set_color(color)
	immediate_mesh.surface_add_vertex(to_point)  # End point

	immediate_mesh.surface_end()
