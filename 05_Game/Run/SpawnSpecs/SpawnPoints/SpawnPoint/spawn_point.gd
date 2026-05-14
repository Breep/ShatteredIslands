# Base node for spawn point markers placed in Tavern/Fighting formation builders.
# Carries an optional editor-time visual (a child named "VisualToBeDestroyed"
# with unique_name_in_owner = true) that is queue_freed at runtime.
class_name SpawnPoint
extends Node3D


func _ready() -> void:
	var visual: Node = get_node_or_null(^"%VisualToBeDestroyed")
	if visual != null:
		visual.queue_free()
