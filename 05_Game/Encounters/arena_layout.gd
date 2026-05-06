# Pure data describing a hex-based arena layout: which hexes belong to the player camp,
# which to the enemy camp. Reusable across multiple island scenes that share the same grid.
# Used by EncounterSnapshotter for placement validation, and by EncounterLoader at runtime.
class_name ArenaLayout
extends Resource


# ============================== Enums ==============================
#region Enums
enum Camp { NONE, PLAYER, ENEMY }
#endregion


# ============================== Export ==============================
#region Export
@export_range(0.1, 5.0, 0.05) var hex_size: float = 1.0
@export var orientation: HexUtils.Orientation = HexUtils.Orientation.POINTY_TOP
@export var world_origin: Vector3 = Vector3.ZERO
@export var player_camp_hexes: Array[Vector2i] = []
@export var enemy_camp_hexes: Array[Vector2i] = []
#endregion


# ============================== Public functions ==============================
#region Public functions
func is_valid_hex(coord: Vector2i, camp: Camp = Camp.NONE) -> bool:
	match camp:
		Camp.PLAYER:
			return coord in player_camp_hexes
		Camp.ENEMY:
			return coord in enemy_camp_hexes
		_:
			return coord in player_camp_hexes or coord in enemy_camp_hexes


func get_camp_for_hex(coord: Vector2i) -> Camp:
	if coord in player_camp_hexes:
		return Camp.PLAYER
	if coord in enemy_camp_hexes:
		return Camp.ENEMY
	return Camp.NONE


func set_camp_for_hex(coord: Vector2i, camp: Camp) -> void:
	player_camp_hexes.erase(coord)
	enemy_camp_hexes.erase(coord)
	match camp:
		Camp.PLAYER:
			player_camp_hexes.append(coord)
		Camp.ENEMY:
			enemy_camp_hexes.append(coord)
		_:
			pass


func clear_all() -> void:
	player_camp_hexes.clear()
	enemy_camp_hexes.clear()


# Apply this layout's camp assignments as colors on a HexGrid (preview / editor tool).
# Tiles outside both camps are colored with none_color.
func apply_to_hex_grid(grid: HexGrid, player_color: Color, enemy_color: Color, none_color: Color) -> void:
	if grid == null: return
	for coord in grid.get_all_coords():
		var camp: Camp = get_camp_for_hex(coord)
		var c: Color = none_color
		match camp:
			Camp.PLAYER: c = player_color
			Camp.ENEMY:  c = enemy_color
			_:           c = none_color
		grid.set_tile_color(coord, c)
#endregion
