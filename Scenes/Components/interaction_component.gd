class_name InteractionComponent
extends Node

# ============================== Export ==============================

@export var meshs: Array[MeshInstance3D]

# ============================== Private variables ==============================

var _parent: Node3D

@onready var _material_overlay: StandardMaterial3D = preload("res://Scenes/Components/default_interact_material_overlay.tres")

# ============================== Node base functions ==============================

func _ready() -> void:
	_parent = get_parent()
	_connect_parent()

# ============================== Private functions ==============================

func _connect_parent() -> void:
	_parent.add_user_signal("focused")
	_parent.add_user_signal("unfocused")
	_parent.add_user_signal("interacted")
	_parent.connect("focused", _on_parent_focused)
	_parent.connect("unfocused", _on_parent_unfocused)
	_parent.connect("interacted", _on_parent_interacted)


func _init_meshs() -> void:
	if meshs.size() > 0:
		return
	
	for child in _parent.get_children():
		if child is MeshInstance3D:
			meshs.append(child)

# ============================== Callbacks ==============================

func _on_parent_focused() -> void:
	print("FOCUSED")
	for mesh in meshs:
		mesh.material_overlay = _material_overlay

func _on_parent_unfocused() -> void:
	print("UNFOCUSED")
	for mesh in meshs:
		mesh.material_overlay = null

func _on_parent_interacted() -> void:
	pass
