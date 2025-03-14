class_name Hero3D
extends Node3D

@onready var _collision_shape: CollisionShape3D = %CollisionShape3D

func get_height() -> float:
	return (_collision_shape.shape as CapsuleShape3D).height
