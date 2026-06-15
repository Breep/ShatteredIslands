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


# Pose éditeur (PAS de spawn runtime) : on instancie la scène telle quelle et on
# la place. spec.spawn_into() est du code runtime qui touche des membres non
# exportés de l'Entity — invalide sur les PlaceHolderScriptInstance de l'éditeur.
# Spec sans scène : marker Node3D vide.
func _instantiate_spec_into(spec: SpawnSpec, container: Node, edited_root: Node) -> bool:
	var packed: PackedScene = _resolve_spec_scene(spec)
	var node: Node = packed.instantiate() if packed != null else Node3D.new()
	container.add_child(node)
	if node is Node3D:
		(node as Node3D).transform = spec.transform
	if spec.display_label != "":
		node.name = spec.display_label
	if edited_root != null:
		node.owner = edited_root
	return true


# EntitySpec : scène résolue depuis la desc de l'entry (modèle unifié), repli sur
# le champ `scene` (markers / props / specs legacy sans entry).
func _resolve_spec_scene(spec: SpawnSpec) -> PackedScene:
	if spec is EntitySpec:
		var es: EntitySpec = spec as EntitySpec
		if es.entry != null and es.entry.desc != null:
			return EntityDesc.resolve_scene(es.entry.desc)
	return spec.scene
