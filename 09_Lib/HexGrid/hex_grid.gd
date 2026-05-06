# A 3D hexagonal grid of width × height cells, rendered as a single MultiMeshInstance3D.
# Each tile carries a persistent state (Normal/Disabled/Selected/Blocked) and an optional
# transient hover state. Mouse picking is handled by a flat Area3D auto-sized to the grid.
@tool
class_name HexGrid
extends Node3D


# ============================== Signals ==============================
#region Signals
signal grid_rebuilt
signal tile_hover_changed(coord: Vector2i, is_hovered: bool)
signal tile_state_changed(coord: Vector2i, new_state: int)
#endregion


# ============================== Enums ==============================
#region Enums
enum TileState { NORMAL, DISABLED, SELECTED, BLOCKED }
#endregion


# ============================== Constants ==============================
#region Constants
const _MULTIMESH_NODE_NAME: StringName = &"HexMultiMesh"
const _AREA_NODE_NAME: StringName = &"HexArea"
const _COLLISION_SHAPE_NAME: StringName = &"CollisionShape3D"
#endregion


# ============================== Export ==============================
#region Export
@export_range(1, 50) var width: int = 11 : set = _set_width
@export_range(1, 50) var height: int = 11 : set = _set_height
@export_range(0.1, 5.0, 0.05) var hex_size: float = 1.0 : set = _set_hex_size
@export var orientation: HexUtils.Orientation = HexUtils.Orientation.POINTY_TOP : set = _set_orientation

@export_group("Colors")
@export var color_normal: Color = Color(0.30, 0.40, 0.50, 0.50) : set = _set_color_normal
@export var color_hover: Color = Color(0.95, 0.85, 0.40, 0.75) : set = _set_color_hover
@export var color_disabled: Color = Color(0.30, 0.30, 0.30, 0.30) : set = _set_color_disabled
@export var color_selected: Color = Color(0.40, 0.85, 0.40, 0.75) : set = _set_color_selected
@export var color_blocked: Color = Color(0.85, 0.30, 0.30, 0.65) : set = _set_color_blocked

@export_group("Shader")
@export var shader: Shader : set = _set_shader
@export_range(0.0, 0.5) var border_thickness: float = 0.1 : set = _set_border_thickness
@export_range(0.1, 5.0) var center_falloff: float = 2.0 : set = _set_center_falloff
@export_range(0.0, 0.5) var edge_softness: float = 0.02 : set = _set_edge_softness
@export var use_hexagonal_shape: bool = true : set = _set_use_hexagonal_shape

@export_group("Interaction")
@export var enable_hover: bool = true

@export_tool_button("Rebuild grid") var _rebuild_button = _build_grid
#endregion


# ============================== Private variables ==============================
#region Private variables
var _multimesh_instance: MultiMeshInstance3D
var _multimesh: MultiMesh
var _material: ShaderMaterial
var _area: Area3D
var _collision_shape: CollisionShape3D

var _tiles: Dictionary[Vector2i, int] = {}
var _states: Dictionary[Vector2i, TileState] = {}

var _hovered_coord: Vector2i = Vector2i.ZERO
var _has_hover: bool = false
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


func get_tile_index(coord: Vector2i) -> int:
	return _tiles.get(coord, -1)


func get_tile_at_world(world_pos: Vector3) -> Vector2i:
	var local: Vector3 = world_pos - global_position
	return HexUtils.world_to_axial(local, hex_size, orientation)


func get_tile_state(coord: Vector2i) -> TileState:
	return _states.get(coord, TileState.NORMAL)


func set_tile_state(coord: Vector2i, state: TileState) -> void:
	if not _tiles.has(coord): return
	if state == TileState.NORMAL:
		_states.erase(coord)
	else:
		_states[coord] = state
	_refresh_tile_color(coord)
	tile_state_changed.emit(coord, state)


func clear_tile_state(coord: Vector2i) -> void:
	set_tile_state(coord, TileState.NORMAL)


func reset_all_tiles() -> void:
	_states.clear()
	_refresh_all_tiles()


func get_hovered_coord() -> Vector2i:
	return _hovered_coord if _has_hover else Vector2i.ZERO


func has_hover() -> bool:
	return _has_hover
#endregion


# ============================== Private functions ==============================
#region Private functions
func _build_grid() -> void:
	if not is_inside_tree(): return

	_ensure_multimesh_instance()
	_ensure_material()
	_ensure_area()

	var mesh: ArrayMesh = HexMesh.create(hex_size, orientation)

	if _multimesh == null:
		_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.use_colors = true
	_multimesh.use_custom_data = false
	_multimesh.mesh = mesh
	_multimesh.instance_count = width * height

	_multimesh_instance.multimesh = _multimesh

	_tiles.clear()
	_has_hover = false
	var idx: int = 0
	for row in height:
		for col in width:
			var hex: Vector2i = HexUtils.offset_to_axial(col, row, orientation)
			var pos: Vector3 = HexUtils.axial_to_world(hex, hex_size, orientation)
			_multimesh.set_instance_transform(idx, Transform3D(Basis(), pos))
			var state: TileState = _states.get(hex, TileState.NORMAL)
			_multimesh.set_instance_color(idx, _color_for_state(state))
			_tiles[hex] = idx
			idx += 1

	_update_collision_shape()
	_update_shader_uniforms()
	grid_rebuilt.emit()


func _ensure_multimesh_instance() -> void:
	if _multimesh_instance != null and is_instance_valid(_multimesh_instance):
		return
	var existing: Node = get_node_or_null(NodePath(_MULTIMESH_NODE_NAME))
	if existing is MultiMeshInstance3D:
		_multimesh_instance = existing
		return
	_multimesh_instance = MultiMeshInstance3D.new()
	_multimesh_instance.name = _MULTIMESH_NODE_NAME
	add_child(_multimesh_instance)


func _ensure_material() -> void:
	if _material == null:
		_material = ShaderMaterial.new()
	if shader != null and _material.shader != shader:
		_material.shader = shader
	if _multimesh_instance != null:
		_multimesh_instance.material_override = _material


func _ensure_area() -> void:
	if _area == null or not is_instance_valid(_area):
		var existing: Node = get_node_or_null(NodePath(_AREA_NODE_NAME))
		if existing is Area3D:
			_area = existing
		else:
			_area = Area3D.new()
			_area.name = _AREA_NODE_NAME
			_area.input_ray_pickable = true
			add_child(_area)
		if not _area.input_event.is_connected(_on_area_input_event):
			_area.input_event.connect(_on_area_input_event)
		if not _area.mouse_exited.is_connected(_on_area_mouse_exited):
			_area.mouse_exited.connect(_on_area_mouse_exited)

	if _collision_shape == null or not is_instance_valid(_collision_shape):
		var existing_shape: Node = _area.get_node_or_null(NodePath(_COLLISION_SHAPE_NAME))
		if existing_shape is CollisionShape3D:
			_collision_shape = existing_shape
		else:
			_collision_shape = CollisionShape3D.new()
			_collision_shape.name = _COLLISION_SHAPE_NAME
			_collision_shape.shape = BoxShape3D.new()
			_area.add_child(_collision_shape)


func _update_collision_shape() -> void:
	if _collision_shape == null or _tiles.is_empty(): return
	var min_x: float = INF
	var max_x: float = -INF
	var min_z: float = INF
	var max_z: float = -INF
	for coord in _tiles.keys():
		var pos: Vector3 = HexUtils.axial_to_world(coord, hex_size, orientation)
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	var pad: float = hex_size
	var size: Vector3 = Vector3(
		(max_x - min_x) + 2.0 * pad,
		0.1,
		(max_z - min_z) + 2.0 * pad
	)
	var center: Vector3 = Vector3((max_x + min_x) * 0.5, 0.0, (max_z + min_z) * 0.5)
	var box: BoxShape3D = _collision_shape.shape as BoxShape3D
	if box != null:
		box.size = size
	_collision_shape.position = center


func _update_shader_uniforms() -> void:
	if _material == null: return
	_material.set_shader_parameter("border_thickness", border_thickness)
	_material.set_shader_parameter("center_falloff", center_falloff)
	_material.set_shader_parameter("edge_softness", edge_softness)
	_material.set_shader_parameter("use_hexagonal_shape", use_hexagonal_shape)
	_material.set_shader_parameter("is_pointy_top", orientation == HexUtils.Orientation.POINTY_TOP)


func _refresh_tile_color(coord: Vector2i) -> void:
	var idx: int = _tiles.get(coord, -1)
	if idx == -1 or _multimesh == null: return
	var c: Color
	if _has_hover and _hovered_coord == coord:
		c = color_hover
	else:
		c = _color_for_state(_states.get(coord, TileState.NORMAL))
	_multimesh.set_instance_color(idx, c)


func _refresh_all_tiles() -> void:
	if _multimesh == null: return
	for coord in _tiles.keys():
		_refresh_tile_color(coord)


func _color_for_state(state: TileState) -> Color:
	match state:
		TileState.DISABLED: return color_disabled
		TileState.SELECTED: return color_selected
		TileState.BLOCKED:  return color_blocked
		_:                  return color_normal


func _set_hover(coord: Vector2i) -> void:
	if not _tiles.has(coord):
		_clear_hover()
		return
	if _has_hover and _hovered_coord == coord:
		return
	var prev_coord: Vector2i = _hovered_coord
	var had_prev: bool = _has_hover
	_hovered_coord = coord
	_has_hover = true
	if had_prev:
		_refresh_tile_color(prev_coord)
		tile_hover_changed.emit(prev_coord, false)
	_refresh_tile_color(coord)
	tile_hover_changed.emit(coord, true)


func _clear_hover() -> void:
	if not _has_hover: return
	var prev: Vector2i = _hovered_coord
	_has_hover = false
	_refresh_tile_color(prev)
	tile_hover_changed.emit(prev, false)
#endregion


# ============================== Callbacks ==============================
#region Callbacks
func _on_area_input_event(_camera: Node, event: InputEvent, position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not enable_hover: return
	if not (event is InputEventMouseMotion): return
	var local: Vector3 = position - global_position
	var hex: Vector2i = HexUtils.world_to_axial(local, hex_size, orientation)
	_set_hover(hex)


func _on_area_mouse_exited() -> void:
	_clear_hover()
#endregion


# ============================== Setters ==============================
#region Setters
func _set_width(v: int) -> void:
	width = max(1, v)
	if is_inside_tree(): _build_grid()


func _set_height(v: int) -> void:
	height = max(1, v)
	if is_inside_tree(): _build_grid()


func _set_hex_size(v: float) -> void:
	hex_size = max(0.01, v)
	if is_inside_tree(): _build_grid()


func _set_orientation(v: HexUtils.Orientation) -> void:
	orientation = v
	if is_inside_tree(): _build_grid()


func _set_color_normal(v: Color) -> void:
	color_normal = v
	if is_inside_tree(): _refresh_all_tiles()


func _set_color_hover(v: Color) -> void:
	color_hover = v
	if is_inside_tree() and _has_hover:
		_refresh_tile_color(_hovered_coord)


func _set_color_disabled(v: Color) -> void:
	color_disabled = v
	if is_inside_tree(): _refresh_all_tiles()


func _set_color_selected(v: Color) -> void:
	color_selected = v
	if is_inside_tree(): _refresh_all_tiles()


func _set_color_blocked(v: Color) -> void:
	color_blocked = v
	if is_inside_tree(): _refresh_all_tiles()


func _set_shader(v: Shader) -> void:
	shader = v
	if is_inside_tree():
		_ensure_material()
		_update_shader_uniforms()


func _set_border_thickness(v: float) -> void:
	border_thickness = v
	_update_shader_uniforms()


func _set_center_falloff(v: float) -> void:
	center_falloff = v
	_update_shader_uniforms()


func _set_edge_softness(v: float) -> void:
	edge_softness = v
	_update_shader_uniforms()


func _set_use_hexagonal_shape(v: bool) -> void:
	use_hexagonal_shape = v
	_update_shader_uniforms()
#endregion
