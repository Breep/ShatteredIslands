# Base spec describing what to spawn at a given Transform.
# `scene` is optional: when null, the spec is a pure marker (no PackedScene to instantiate).
@tool
class_name SpawnSpec
extends Resource

@export var scene: PackedScene
@export var display_label: String = ""

@export var transform: Transform3D = Transform3D()


# Instancie ce spec dans la scène et retourne le node créé. Retourne null si scene == null.
# Le paramètre ctx est ignoré ici — les sous-classes (EntitySpec) peuvent l'utiliser
# pour router le spawn via un manager.
func spawn_into(parent: Node, _ctx: EntityContext = null) -> Node:
	if scene == null:
		return null
	var node: Node = scene.instantiate()
	parent.add_child(node)
	if node is Node3D:
		(node as Node3D).transform = transform
	if display_label != "":
		node.name = display_label
	return node
