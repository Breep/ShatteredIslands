class_name MeleeAttackCommand
extends RefCounted

## Target entity for the melee attack
var target: Entity

## Attack stats (reusing ProjectileStats for damage calculation)
var stats: ProjectileStats


func _init(p_target: Entity, p_stats: ProjectileStats) -> void:
	target = p_target
	stats = p_stats
