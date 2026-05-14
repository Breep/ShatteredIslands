@tool
class_name FormationBuilder
extends Node

@warning_ignore("unused_private_class_variable")
@export_tool_button("Validate") var _validate_btn = _validate

@warning_ignore("unused_private_class_variable")
@export_tool_button("Cleanup") var _cleanup_btn = _cleanup

@export_group("Save")
@export var output_dir: String = "res://05_Game/Run/Formations/Pool/Prototyping/"
@export var formation_id: String = "prototype"
@warning_ignore("unused_private_class_variable")
@export_tool_button("Save") var _snap_btn = _save

#region ============================== Buttons implementation (Public API) ==============================
func _save() -> void:
	pass


func _load() -> void:
	pass


func _cleanup() -> void:
	pass


func _validate() -> bool:
	return true
#endregion


func _instantiate_spec_into(spec: SpawnSpec, container: Node, edited_root: Node) -> bool:
	var node: Node = spec.spawn_into(container)
	if node == null:
		# Pas de scène attachée au spec : marker vide pour l'éditeur
		node = Node3D.new()
		container.add_child(node)
		(node as Node3D).transform = spec.transform
		if spec.display_label != "":
			node.name = spec.display_label
	if edited_root != null:
		node.owner = edited_root
	return true
