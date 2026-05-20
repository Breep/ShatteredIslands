# Static factory for a flat hexagonal mesh (6 vertices, 4 triangles, normal = +Y).
# Vertices are placed at exact geometric angles to ensure perfect tiling with HexUtils.axial_to_world.
class_name HexMesh


# ============================== Public functions ==============================
#region Public functions
static func create(hex_size: float, orientation: HexUtils.Orientation = HexUtils.Orientation.POINTY_TOP) -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var indices: PackedInt32Array = PackedInt32Array()

	var angle_offset: float = PI / 6.0 if orientation == HexUtils.Orientation.POINTY_TOP else 0.0

	for i in 6:
		var angle: float = angle_offset + float(i) * PI / 3.0
		var x: float = hex_size * cos(angle)
		var z: float = hex_size * sin(angle)
		vertices.append(Vector3(x, 0.0, z))
		normals.append(Vector3.UP)
		uvs.append(Vector2(0.5 + 0.5 * cos(angle), 0.5 + 0.5 * sin(angle)))

	# Triangle fan from vertex 0: (0,1,2), (0,2,3), (0,3,4), (0,4,5)
	for i in range(1, 5):
		indices.append(0)
		indices.append(i)
		indices.append(i + 1)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
#endregion
