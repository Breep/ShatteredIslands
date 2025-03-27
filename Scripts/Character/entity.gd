class_name Entity
extends CharacterBody3D

func _recursive_propagate_spawn_signal(node: Node, signal_name: String) -> void:
	if node.has_signal(signal_name):
		print("Found a parent (", node.name, " with the corresponding signal !")
		node.emit_signal(signal_name, self)
	else:
		_recursive_propagate_spawn_signal(node.get_parent(), signal_name)
