class_name ProjectileComponent
extends EntityComponent

var _spawn_manager: SpawnManager

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.projectile != null and _owner.projectile != self:
		Verbose.trace("Override: ProjectileComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.projectile.queue_free()
	_owner.projectile = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.projectile != self:
		return

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		Verbose.error("Trying to connect to a <null> SpawnManager", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager = spawn_manager


func projectile_attack(target: Entity, projectile_type: Projectile.Type, projectile_spawn: Node3D, projectile_stats: ProjectileStats, is_auto_attack: bool = false) -> void:
	if _owner.alterations.has_timed(Alteration.Type.STUN):
		return

	if not is_auto_attack and _owner.alterations.has_timed(Alteration.Type.SILENCE):
		Verbose.debug("Projectile blocked by SILENCE on " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
		return

	if _spawn_manager == null:
		Verbose.error("No SpawnManager connected", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)
