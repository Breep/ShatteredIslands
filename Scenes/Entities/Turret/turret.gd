class_name Turret
extends Node3D

@export var _projectile_spawn_point: SpawnPoint
@export var _auto_attack_module: AutoAttackModule

var target: Entity

func _ready() -> void:
	_auto_attack_module.target_changed.connect(_on_auto_attack_module_target_changed)

func _process(delta: float) -> void:
	if target != null:
		look_at(target.global_position + 1 * Vector3.UP)


func _on_auto_attack_module_target_changed(new_target: Entity) -> void:
	target = new_target
