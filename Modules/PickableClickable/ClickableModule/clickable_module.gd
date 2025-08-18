class_name ClickableModule
extends Node

# ============================== Public variable ==============================

const CLICKABLE_META: String = "clickable_module"
var focus_locked: bool = false # True if the object can't be focused
var select_locked: bool = false # True if the object can't be interacted

# ============================== Export ==============================

@export var _meshs: Array[MeshInstance3D]
@export var _nodes_where_to_find_meshs: Array[Node3D]
@export var _owner: Node3D
@export var _scale_div_grow: float = 1.0

# ============================== Private variables ==============================

var _material_overlay: StandardMaterial3D = preload("res://VFX/Shaders/outline/Outline_3D/simple_outline.tres")
var _is_focused: bool = false
var _is_selected: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	if _owner == null:
		printerr("ClickableModule: No owner set [", get_path(), "]")
		return
	
	_connect_to_owner()
	_init_meshs()

# ============================== Public functions ==============================

func focus() -> void:
	if _is_focused or focus_locked: return
	_is_focused = true
	_focus()


func unfocus() -> void:
	if not _is_focused or focus_locked: return
	_is_focused = false
	_unfocus()


func select() -> void:
	if _is_selected or select_locked: return
	_is_selected = true
	Events.signal_clickable_cliked(_owner)
	_select()


func unselect() -> void:
	if not _is_selected or select_locked: return
	_is_selected = false
	_unselect()

# ============================== Private functions ==============================

func _connect_to_owner() -> void:
	_owner.set_meta(CLICKABLE_META, self)


func _init_meshs() -> void:
	if not _meshs.is_empty():
		return
	
	if not _nodes_where_to_find_meshs.is_empty():
		for node in _nodes_where_to_find_meshs:
			_recursive_find_all_meshs(node)
		return
	#
	#_recursive_find_all_meshs(_owner)


func _recursive_find_all_meshs(node: Node3D) -> void:
	for child in node.get_children(true):
		if child is Node3D:
			_recursive_find_all_meshs(child)
	if node is MeshInstance3D:
		_meshs.append(node)

# ============================== Callbacks ==============================

func _focus() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	for mesh in _meshs:
		if mesh != null and not mesh.is_queued_for_deletion():
			mesh.material_overlay = _material_overlay
			(mesh.material_overlay as StandardMaterial3D).grow = true
			(mesh.material_overlay as StandardMaterial3D).grow_amount = 0.03 / _scale_div_grow
	if _owner.has_method("_on_clickable_module_focused"):
		_owner.call("_on_clickable_module_focused")


func _unfocus() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	for mesh in _meshs:
		if mesh != null and not mesh.is_queued_for_deletion():
			mesh.material_overlay = null
	if _owner.has_method("_on_clickable_module_unfocused"):
		_owner.call("_on_clickable_module_unfocused")


func _select() -> void:
	if _owner.has_method("_on_clickable_module_selected"):
		_owner.call("_on_clickable_module_selected")


func _unselect() -> void:
	if _owner.has_method("_on_clickable_module_unselected"):
		_owner.call("_on_clickable_module_unselected")
