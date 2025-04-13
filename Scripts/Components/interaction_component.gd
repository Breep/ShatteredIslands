class_name InteractionComponent
extends Node

# ============================== Export ==============================

@export var _meshs: Array[MeshInstance3D]
@export var _nodes_where_to_find_meshs: Array[Node3D]

# ============================== Private variables ==============================

var _parent: Node3D

@onready var _material_overlay: StandardMaterial3D = preload("res://Scenes/Components/default_interact_material_overlay.tres")

# ============================== Node base functions ==============================

func _ready() -> void:
	_parent = get_parent()
	_connect_parent()
	_init_meshs()

# ============================== Private functions ==============================

func _connect_parent() -> void:
	_parent.add_user_signal("focused")
	_parent.add_user_signal("unfocused")
	_parent.add_user_signal("interacted")
	_parent.connect("focused", _on_parent_focused)
	_parent.connect("unfocused", _on_parent_unfocused)
	_parent.connect("interacted", _on_parent_interacted)


func _init_meshs() -> void:
	if not _meshs.is_empty():
		return
	
	if not _nodes_where_to_find_meshs.is_empty():
		for node in _nodes_where_to_find_meshs:
			_recursive_find_all_meshs(node)
		return
	
	_recursive_find_all_meshs(_parent)


func _recursive_find_all_meshs(node: Node3D) -> void:
	for child in node.get_children():
		if child is Node3D:
			_recursive_find_all_meshs(child)
	if node is MeshInstance3D:
		_meshs.append(node)

# ============================== Callbacks ==============================

func _on_parent_focused() -> void:
	for mesh in _meshs:
		mesh.material_overlay = _material_overlay


func _on_parent_unfocused() -> void:
	for mesh in _meshs:
		mesh.material_overlay = null


func _on_parent_interacted() -> void:
	print("Interracted on: ", _parent.name)
	if _parent.has_method("_on_interaction_component_interacted"):
		_parent.call("_on_interaction_component_interacted")
