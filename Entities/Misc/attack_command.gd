class_name AttackCommand
extends Resource

var target: Entity
var projectile_type: Projectile.Type
var spawn_node: Node3D
var stats: ProjectileStats

func setup(_target: Entity, _type: Projectile.Type, _spawn: Node3D, _stats: ProjectileStats):
	target = _target
	projectile_type = _type
	spawn_node = _spawn
	stats = _stats
	return self
