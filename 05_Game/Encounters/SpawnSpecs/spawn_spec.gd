class_name SpawnSpec
extends Resource

@export var entity_scene: PackedScene
@export var display_label: String = ""

@export var transform: Transform3D = Transform3D()

var free_position: Vector3:
	get: return transform.origin
	set(v): transform.origin = v

var rotation_y: float:
	get: return transform.basis.get_euler().y
	set(v): transform = Transform3D(Basis.from_euler(Vector3(0, v, 0)), transform.origin)
