class_name Turret
extends Node3D

@export var _projectile_spawn_point: SpawnPoint # TODO Maybe, instead of AutoAttackModule to use a SpawnPoint, maybe it should use a Turret.attack()
@export var _auto_attack_module: AutoAttackModule

var target: Entity

func _ready() -> void:
	_auto_attack_module.target_changed.connect(_on_auto_attack_module_target_changed)

func _process(_delta: float) -> void:
	if target != null:
		look_at(target.global_position + 1 * Vector3.UP) #, delta, 0.1)

func get_projectile_spawn_point() -> Node3D:
	return _projectile_spawn_point

func _on_auto_attack_module_target_changed(new_target: Entity) -> void:
	target = new_target


#func _smooth_look_at(target_position: Vector3, delta: float, rotate_speed) -> void:
	#var target_direction = (target_position - global_position).normalized()
	#var target_basis = Basis().looking_at(target_direction)
	#var current_scale = global_transform.basis.get_scale()
	#var smoothed_basis = target_basis.orthonormalized().slerp(target_basis.orthonormalized(), delta * rotate_speed)
	#smoothed_basis.scale(current_scale)
	#global_transform.basis = smoothed_basis
	
