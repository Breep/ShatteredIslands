class_name Projectile
extends Area3D

## Base projectile class that handles collision and callbacks.
## Movement is delegated to a ProjectileTrajectory instance.

# === ENUMS ===
enum Type {
	SHADOW_BOLT,
	VENOMOUS_DART,
	SNAKE,
	COSMIC_BOLT,
	SHIELD_THROW
}

# === EXPORTS ===
@export var trajectory: ProjectileTrajectory
@export var lifetime_max: float = 6.0

# === RUNTIME ===
var _source: Entity
var _target: Entity
var _stats: ProjectileStats

var _hit_history: Array[Entity] = []
var _life: float = 0.0


## Initialize the projectile with _source, _target, and _stats.
## Must be called before adding to scene tree.
func init(p_source: Entity, p_target: Entity, p_stats: ProjectileStats) -> Projectile:
	_source = p_source
	_target = p_target
	_stats = p_stats
	return self


func _ready() -> void:
	if _stats == null:
		Verbose.error("No _stats (null) -> queue_freeing myself", Verbose.Category.PROJECTILE)
	if _target and _target.died and not _target.died.is_connected(_on_target_died):
		_target.died.connect(_on_target_died)
	
	# Execute spawn callbacks
	for cb: Callable in _stats.on_spawn_callbacks:
		if cb.is_valid():
			cb.call({"projectile": self, "_source": _source, "_target": _target})
	
	# Initialize trajectory
	if trajectory:
		trajectory = trajectory.duplicate()
		trajectory.init(self, _source, _target)
	else:
		Verbose.error("No trajectory assigned to projectile [" + name + "]", Verbose.Category.PROJECTILE)
		queue_free()
		return
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_life += delta
	
	# Safety timeout
	if _life > lifetime_max:
		queue_free()
		return
	
	# Delegate movement to trajectory
	if trajectory:
		trajectory.update(delta)


func _on_body_entered(body: Node3D) -> void:
	Verbose.trace("Body entered: " + body.name, Verbose.Category.PROJECTILE)
	if not body is Entity: return
	
	var hit_target: Entity = body
	
	if hit_target in _hit_history or hit_target != _target:
		return
	
	_hit_history.append(hit_target)
	
	# Execute all hit callbacks
	for cb: Callable in _stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				"source": _source,
				"target": hit_target,
				"projectile": self,
				"position": global_position
			})
	
	# Handle bouncing if remaining bounces
	if _stats.bounces_remaining > 0:
		_handle_bounce(hit_target)
	else:
		# No more bounces, destroy projectile
		queue_free()


func _handle_bounce(from_target: Entity) -> void:
	_stats.bounces_remaining -= 1
	
	if not _source or not _source.target_module:
		queue_free()
		return
	
	var new_target := _source.target_module.get_target_from(
		from_target.global_position,
		TargetModule.TargettingFromStrategy.CLOSEST_ENEMY,
		_hit_history
	)
	
	if new_target:
		_target = new_target
		if _target.died and not _target.died.is_connected(_on_target_died):
			_target.died.connect(_on_target_died)
		
		# Tell trajectory to retarget
		if trajectory:
			trajectory.retarget(new_target)
	else:
		# No valid _target found, destroy projectile
		queue_free()


func _on_target_died(_who) -> void:
	queue_free()
