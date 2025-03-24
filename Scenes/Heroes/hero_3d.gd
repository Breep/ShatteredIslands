class_name Hero3D
extends Node3D

@export var hero_id: Hero.HeroId

@onready var _collision_shape: CollisionShape3D = %CollisionShape3D

func get_height() -> float:
	return (_collision_shape.shape as CapsuleShape3D).height


func _on_interaction_component_interacted() -> void:
	Events.hero_interacted.emit(hero_id)
