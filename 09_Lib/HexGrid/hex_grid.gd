# A 3D hexagonal grid that arranges HexTile scene instances in a width × height layout.
# Each tile is a real Node3D (own mesh, material, picking Area3D, signals).
# HexGrid reads hex_size / orientation from the tile scene to guarantee proper tiling, and
# relays per-tile signals (hover/click/state) for callers that prefer a single subscription.
@tool
class_name HexGrid
extends Node3D


# ============================== Signals ==============================
#region Signals
signal grid_rebuilt
signal tile_hovered(coord: Vector2i)
signal tile_unhovered(coord: Vector2i)
signal tile_clicked(coord: Vector2i, button_index: int)
signal tile_state_changed(coord: Vector2i, new_state: int)
#endregion


# ============================== Constants ==============================
#region Constants
const _CONTAINER_NAME: StringName = &"TilesContainer"
#endregion


# ============================== Export ==============================
#region Export
@export_range(1, 50) var width: int = 11 : set = _set_width
@export_range(1, 50) var height: int = 11 : set = _set_height
@export var hex_tile_scene: PackedScene : set = _set_hex_tile_scene
@export_tool_button("Rebuild grid") var _rebuild_button = _build_grid
#endregion


# ============================== Private variables ==============================
#region Private variables
var _container: Node3D
var _tiles: Dictionary[Vector2i, HexTile] = {}
#endregion


# ============================== Node base functions ==============================
#region Node base functions
func _ready() -> void:
	_build_grid()
#endregion


# ============================== Public functions ==============================
#region Public functions
func has_tile(coord: Vector2i) -> bool:
	return _tiles.has(coord)


func get_tile(coord: Vector2i) -> HexTile:
	return _tiles.get(coord, null)


func get_all_coords() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(_tiles.keys())
	return result


func get_all_tiles() -> Array[HexTile]:
	var result: Array[HexTile] = []
	result.assign(_tiles.values())
	return result


func get_tile_at_world(world_pos: Vector3) -> HexTile:
	if hex_tile_scene == null: return null
	var size: float = _peek_tile_hex_size()
	var orient: HexUtils.Orientation = _peek_tile_orientation()
	var local: Vector3 = world_pos - global_position
	var hex: Vector2i = HexUtils.world_to_axial(local, size, orient)
	return get_tile(hex)


func set_tile_state(coord: Vector2i, state: HexTile.TileState) -> void:
	var tile: HexTile = _tiles.get(coord, null)
	if tile == null: return
	tile.set_state(state)


func get_tile_state(coord: Vector2i) -> HexTile.TileState:
	var tile: HexTile = _tiles.get(coord, null)
	if tile == null: return HexTile.TileState.NORMAL
	return tile.get_state()


func set_tile_color(coord: Vector2i, c: Color) -> void:
	var tile: HexTile = _tiles.get(coord, null)
	if tile == null: return
	tile.set_color_override(c)


func reset_all_tiles() -> void:
	for tile in _tiles.values():
		tile.set_state(HexTile.TileState.NORMAL)
		tile.clear_color_override()
#endregion


# ============================== Private functions ==============================
#region Private functions
func _build_grid() -> void:
	if not is_inside_tree(): return
	if hex_tile_scene == null:
		push_warning("HexGrid: hex_tile_scene is null, nothing to build")
		return

	_ensure_container()
	for child in _container.get_children():
		child.queue_free()
	_tiles.clear()

	var sample: HexTile = hex_tile_scene.instantiate() as HexTile
	if sample == null:
		push_error("HexGrid: hex_tile_scene root is not a HexTile")
		return
	var tile_hex_size: float = sample.hex_size
	var tile_orientation: HexUtils.Orientation = sample.orientation
	sample.queue_free()

	for row in height:
		for col in width:
			var hex_coord: Vector2i = HexUtils.offset_to_axial(col, row, tile_orientation)
			var pos: Vector3 = HexUtils.axial_to_world(hex_coord, tile_hex_size, tile_orientation)
			var tile: HexTile = hex_tile_scene.instantiate() as HexTile
			tile.coord = hex_coord
			tile.position = pos
			_container.add_child(tile)
			_connect_tile_signals(tile)
			_tiles[hex_coord] = tile

	grid_rebuilt.emit()


func _ensure_container() -> void:
	if _container != null and is_instance_valid(_container):
		return
	var existing: Node = get_node_or_null(NodePath(_CONTAINER_NAME))
	if existing is Node3D:
		_container = existing
		return
	_container = Node3D.new()
	_container.name = _CONTAINER_NAME
	add_child(_container)


func _connect_tile_signals(tile: HexTile) -> void:
	tile.hovered.connect(_on_tile_hovered)
	tile.unhovered.connect(_on_tile_unhovered)
	tile.clicked.connect(_on_tile_clicked)
	tile.state_changed.connect(_on_tile_state_changed)


func _peek_tile_orientation() -> HexUtils.Orientation:
	if hex_tile_scene == null:
		return HexUtils.Orientation.POINTY_TOP
	var sample: HexTile = hex_tile_scene.instantiate() as HexTile
	if sample == null:
		return HexUtils.Orientation.POINTY_TOP
	var o: HexUtils.Orientation = sample.orientation
	sample.queue_free()
	return o


func _peek_tile_hex_size() -> float:
	if hex_tile_scene == null:
		return 1.0
	var sample: HexTile = hex_tile_scene.instantiate() as HexTile
	if sample == null:
		return 1.0
	var s: float = sample.hex_size
	sample.queue_free()
	return s
#endregion


# ============================== Callbacks ==============================
#region Callbacks
func _on_tile_hovered(coord: Vector2i) -> void:
	tile_hovered.emit(coord)


func _on_tile_unhovered(coord: Vector2i) -> void:
	tile_unhovered.emit(coord)


func _on_tile_clicked(coord: Vector2i, button_index: int) -> void:
	tile_clicked.emit(coord, button_index)


func _on_tile_state_changed(coord: Vector2i, new_state: int) -> void:
	tile_state_changed.emit(coord, new_state)
#endregion


# ============================== Setters ==============================
#region Setters
func _set_width(v: int) -> void:
	width = max(1, v)
	if is_inside_tree(): _build_grid()


func _set_height(v: int) -> void:
	height = max(1, v)
	if is_inside_tree(): _build_grid()


func _set_hex_tile_scene(v: PackedScene) -> void:
	hex_tile_scene = v
	if is_inside_tree(): _build_grid()
#endregion
