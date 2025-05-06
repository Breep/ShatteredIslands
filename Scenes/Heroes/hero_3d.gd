class_name Hero3D
extends Node3D

@export var hero_id: Hero.HeroId

@onready var _collision_shape: CollisionShape3D = %CollisionShape3D
@onready var _animation_tree: AnimationTree = %AnimationTree

func get_height() -> float:
	return (_collision_shape.shape as CapsuleShape3D).height


func attach_to_attack_done_signal(attack_done_signal: Signal) -> void:
	attack_done_signal.connect(_on_attack_done)


func _on_interaction_component_interacted() -> void:
	Events.hero_interacted.emit(hero_id)


func _on_attack_done() -> void:
	if _animation_tree == null:
		return
	_animation_tree["parameters/conditions/is_attacking"] = true
	await get_tree().create_timer(0.1).timeout
	_animation_tree["parameters/conditions/is_attacking"] = false
