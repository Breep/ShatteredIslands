class_name ActionSenderProjectileModule
extends ActionSenderModule

var _spawn_manager: SpawnManager

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		Verbose.error("Trying to connect to a <null> SpawnManager", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager = spawn_manager


func projectile_attack(target: Entity, projectile_type: Projectile.Type, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if _spawn_manager == null:
		Verbose.error("No SpawnManager connected", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)
