# A single hex tile rendered as a flat hexagonal mesh with its own shader material.
# Owns its visual state (Normal/Hover/Disabled/Selected/Blocked) and its picking Area3D.
# Lives standalone (testable in isolation) or as a child of HexGrid.
@tool
class_name HexTile
extends Node3D


# ============================== Signals ==============================
#region Signals
signal hovered(coord: Vector2i)
signal unhovered(coord: Vector2i)
signal clicked(coord: Vector2i, button_index: int)
signal state_changed(coord: Vector2i, new_state: int)
#endregion


# ============================== Enums ==============================
#region Enums
enum TileState { NORMAL, DISABLED, SELECTED, BLOCKED }
#endregion


# ============================== Constants ==============================
#region Constants
const _MESH_NODE_NAME: StringName = &"MeshInstance3D"
const _AREA_NODE_NAME: StringName = &"PickArea"
const _COLLISION_NODE_NAME: StringName = &"CollisionShape3D"
#endregion


# ============================== Export ==============================
#region Export
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
@export var enable_picking: bool = true
#endregion


# ============================== Public variables ==============================
#region Public variables
var coord: Vector2i = Vector2i.ZERO
#endregion


# ============================== Private variables ==============================
#region Private variables
var _state: TileState = TileState.NORMAL
var _is_hovered: bool = false
var _color_override: Color = Color(0, 0, 0, 0)
var _has_color_override: bool = false

var _mesh_instance: MeshInstance3D
var _material: ShaderMaterial
var _area: Area3D
var _collision_shape: CollisionShape3D
#endregion


# ============================== Node base functions ==============================
#region Node base functions
func _ready() -> void:
	_ensure_mesh_instance()
	_ensure_material()
	_ensure_picking_area()
	_rebuild_mesh()
	_rebuild_collision()
	_apply_current_color()
#endregion


# ============================== Public functions ==============================
#region Public functions
func set_state(new_state: TileState) -> void:
	if _state == new_state: return
	_state = new_state
	if _has_color_override:
		_has_color_override = false
	_apply_current_color()
	state_changed.emit(coord, new_state)


func get_state() -> TileState:
	return _state


func is_hovered() -> bool:
	return _is_hovered


# Force a color outside the state system (for ArenaLayout preview, debug).
# Cleared automatically on state_change or hover.
func set_color_override(c: Color) -> void:
	_color_override = c
	_has_color_override = true
	_apply_current_color()


func clear_color_override() -> void:
	_has_color_override = false
	_apply_current_color()
#endregion


# ============================== Private functions ==============================
#region Private functions
func _ensure_mesh_instance() -> void:
	if _mesh_instance != null and is_instance_valid(_mesh_instance):
		return
	var existing: Node = get_node_or_null(NodePath(_MESH_NODE_NAME))
	if existing is MeshInstance3D:
		_mesh_instance = existing
		return
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = _MESH_NODE_NAME
	add_child(_mesh_instance)


func _ensure_material() -> void:
	if _material == null:
		_material = ShaderMaterial.new()
	if shader != null and _material.shader != shader:
		_material.shader = shader
	if _mesh_instance != null:
		_mesh_instance.material_override = _material
	_update_shader_uniforms()


func _ensure_picking_area() -> void:
	if _area == null or not is_instance_valid(_area):
		var existing: Node = get_node_or_null(NodePath(_AREA_NODE_NAME))
		if existing is Area3D:
			_area = existing
		else:
			_area = Area3D.new()
			_area.name = _AREA_NODE_NAME
			_area.input_ray_pickable = true
			add_child(_area)
		if not _area.mouse_entered.is_connected(_on_mouse_entered):
			_area.mouse_entered.connect(_on_mouse_entered)
		if not _area.mouse_exited.is_connected(_on_mouse_exited):
			_area.mouse_exited.connect(_on_mouse_exited)
		if not _area.input_event.is_connected(_on_area_input_event):
			_area.input_event.connect(_on_area_input_event)

	if _collision_shape == null or not is_instance_valid(_collision_shape):
		var existing_shape: Node = _area.get_node_or_null(NodePath(_COLLISION_NODE_NAME))
		if existing_shape is CollisionShape3D:
			_collision_shape = existing_shape
		else:
			_collision_shape = CollisionShape3D.new()
			_collision_shape.name = _COLLISION_NODE_NAME
			_area.add_child(_collision_shape)

	_area.input_ray_pickable = enable_picking


func _rebuild_mesh() -> void:
	if _mesh_instance == null: return
	_mesh_instance.mesh = HexMesh.create(hex_size, orientation)


func _rebuild_collision() -> void:
	if _collision_shape == null: return
	var shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	var pts: PackedVector3Array = PackedVector3Array()
	var angle_offset: float = PI / 6.0 if orientation == HexUtils.Orientation.POINTY_TOP else 0.0
	var thickness: float = 0.05
	for i in 6:
		var angle: float = angle_offset + float(i) * PI / 3.0
		var x: float = hex_size * cos(angle)
		var z: float = hex_size * sin(angle)
		pts.append(Vector3(x, thickness, z))
		pts.append(Vector3(x, -thickness, z))
	shape.points = pts
	_collision_shape.shape = shape


func _update_shader_uniforms() -> void:
	if _material == null: return
	_material.set_shader_parameter("border_thickness", border_thickness)
	_material.set_shader_parameter("center_falloff", center_falloff)
	_material.set_shader_parameter("edge_softness", edge_softness)
	_material.set_shader_parameter("use_hexagonal_shape", use_hexagonal_shape)
	_material.set_shader_parameter("is_pointy_top", orientation == HexUtils.Orientation.POINTY_TOP)


func _apply_current_color() -> void:
	if _material == null: return
	var c: Color
	if _has_color_override:
		c = _color_override
	elif _is_hovered:
		c = color_hover
	else:
		c = _color_for_state(_state)
	_material.set_shader_parameter("base_color", c)


func _color_for_state(state: TileState) -> Color:
	match state:
		TileState.DISABLED: return color_disabled
		TileState.SELECTED: return color_selected
		TileState.BLOCKED:  return color_blocked
		_:                  return color_normal
#endregion


# ============================== Callbacks ==============================
#region Callbacks
func _on_mouse_entered() -> void:
	if not enable_picking: return
	_is_hovered = true
	if _has_color_override:
		_has_color_override = false
	_apply_current_color()
	hovered.emit(coord)


func _on_mouse_exited() -> void:
	if not enable_picking: return
	_is_hovered = false
	_apply_current_color()
	unhovered.emit(coord)


func _on_area_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not enable_picking: return
	if event is InputEventMouseButton:
		var btn: InputEventMouseButton = event as InputEventMouseButton
		if btn.pressed:
			clicked.emit(coord, btn.button_index)
#endregion


# ============================== Setters ==============================
#region Setters
func _set_hex_size(v: float) -> void:
	hex_size = max(0.01, v)
	if is_inside_tree():
		_rebuild_mesh()
		_rebuild_collision()


func _set_orientation(v: HexUtils.Orientation) -> void:
	orientation = v
	if is_inside_tree():
		_rebuild_mesh()
		_rebuild_collision()
		_update_shader_uniforms()


func _set_color_normal(v: Color) -> void:
	color_normal = v
	if is_inside_tree(): _apply_current_color()


func _set_color_hover(v: Color) -> void:
	color_hover = v
	if is_inside_tree() and _is_hovered: _apply_current_color()


func _set_color_disabled(v: Color) -> void:
	color_disabled = v
	if is_inside_tree(): _apply_current_color()


func _set_color_selected(v: Color) -> void:
	color_selected = v
	if is_inside_tree(): _apply_current_color()


func _set_color_blocked(v: Color) -> void:
	color_blocked = v
	if is_inside_tree(): _apply_current_color()


func _set_shader(v: Shader) -> void:
	shader = v
	if is_inside_tree():
		_ensure_material()
		_apply_current_color()


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
