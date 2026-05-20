# Static utilities to convert between hex axial coordinates (q, r) and 3D world positions.
# Used by ArenaLayout for placement, EncounterSnapshotter for snap, and EncounterLoader for spawn.
class_name HexUtils


# ============================== Enums ==============================
#region Enums
enum Orientation { POINTY_TOP, FLAT_TOP }
#endregion


# ============================== Public functions ==============================
#region Public functions
static func axial_to_world(hex: Vector2i, hex_size: float, orientation: HexUtils.Orientation = Orientation.POINTY_TOP, origin: Vector3 = Vector3.ZERO) -> Vector3:
	match orientation:
		Orientation.FLAT_TOP:
			return _axial_to_world_flat(hex, hex_size, origin)
		_:
			return _axial_to_world_pointy(hex, hex_size, origin)


static func world_to_axial(world_pos: Vector3, hex_size: float, orientation: HexUtils.Orientation = Orientation.POINTY_TOP, origin: Vector3 = Vector3.ZERO) -> Vector2i:
	match orientation:
		Orientation.FLAT_TOP:
			return _world_to_axial_flat(world_pos, hex_size, origin)
		_:
			return _world_to_axial_pointy(world_pos, hex_size, origin)


# Convert a (col, row) offset coord (rectangular grid) to axial (q, r).
# Pointy-top uses odd-r offset, flat-top uses odd-q offset.
static func offset_to_axial(col: int, row: int, orientation: HexUtils.Orientation = Orientation.POINTY_TOP) -> Vector2i:
	match orientation:
		Orientation.FLAT_TOP:
			return Vector2i(col, row - floori(col / 2.0))
		_:
			return Vector2i(col - floori(row / 2.0), row)
#endregion


# ============================== Private functions ==============================
#region Private functions
static func _axial_to_world_pointy(hex: Vector2i, hex_size: float, origin: Vector3) -> Vector3:
	var x: float = hex_size * (sqrt(3.0) * hex.x + sqrt(3.0) * 0.5 * hex.y)
	var z: float = hex_size * (1.5 * hex.y)
	return Vector3(x, 0.0, z) + origin


static func _world_to_axial_pointy(world_pos: Vector3, hex_size: float, origin: Vector3) -> Vector2i:
	var local: Vector3 = world_pos - origin
	var q: float = (sqrt(3.0) / 3.0 * local.x - 1.0 / 3.0 * local.z) / hex_size
	var r: float = (2.0 / 3.0 * local.z) / hex_size
	return _axial_round(Vector2(q, r))


static func _axial_to_world_flat(hex: Vector2i, hex_size: float, origin: Vector3) -> Vector3:
	var x: float = hex_size * (1.5 * hex.x)
	var z: float = hex_size * (sqrt(3.0) * 0.5 * hex.x + sqrt(3.0) * hex.y)
	return Vector3(x, 0.0, z) + origin


static func _world_to_axial_flat(world_pos: Vector3, hex_size: float, origin: Vector3) -> Vector2i:
	var local: Vector3 = world_pos - origin
	var q: float = (2.0 / 3.0 * local.x) / hex_size
	var r: float = (-1.0 / 3.0 * local.x + sqrt(3.0) / 3.0 * local.z) / hex_size
	return _axial_round(Vector2(q, r))


# Cube-rounding for stable conversion at hex boundaries.
static func _axial_round(frac_hex: Vector2) -> Vector2i:
	var x: float = frac_hex.x
	var z: float = frac_hex.y
	var y: float = -x - z
	var rx: float = round(x)
	var ry: float = round(y)
	var rz: float = round(z)
	var dx: float = absf(rx - x)
	var dy: float = absf(ry - y)
	var dz: float = absf(rz - z)
	if dx > dy and dx > dz:
		rx = -ry - rz
	elif dy > dz:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector2i(int(rx), int(rz))
#endregion
