@tool
class_name FormationBuilder
extends Node

@warning_ignore("unused_private_class_variable")
@export_tool_button("Validate") var _validate_btn = _validate

@warning_ignore("unused_private_class_variable")
@export_tool_button("Cleanup") var _cleanup_btn = _cleanup

@export_group("Save")
@export var output_dir: String = "res://05_Game/Encounters/Pool/Prototyping/"
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
	var node: Node
	if spec.scene == null:
		node = Node3D.new()
	else:
		node = spec.scene.instantiate()

	container.add_child(node)
	if edited_root != null:
		node.owner = edited_root
	if node is Node3D:
		(node as Node3D).transform = spec.transform
	if spec.display_label != "":
		node.name = spec.display_label
	if node is Entity and spec is EntitySpec and spec.stats_override != null:
		(node as Entity).custom_base_stats = spec.stats_override.duplicate(true)
	return true
