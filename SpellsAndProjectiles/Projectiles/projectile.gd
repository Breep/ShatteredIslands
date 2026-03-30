class_name Projectile
extends Area3D

signal target_hit(entity: Entity, gpos: Vector3)

# === CONSTANTS ===
const TICKS_PER_SECOND: int = 60
## Squared hit radius in world units (~0.63 unit radius). Adjust per projectile if needed.
const HIT_DISTANCE_SQ: float = 0.4

# === ENUMS ===
enum Type {
	SHADOW_BOLT,
	VENOMOUS_DART,
	SNAKE,
	COSMIC_BOLT,
	SHIELD_THROW,
	POISON_FLASK,
	SMALL_EGG,
	FIRE_BALL,
}

# === EXPORTS ===
@export var trajectory: ProjectileTrajectory
@export var lifetime_max: float = 6.0

var uid: int = -1

# === RUNTIME ===
var _source: Entity
var _target: Entity
var _stats: ProjectileStats

var _hit_history: Array[Entity] = []
var _life_ticks: int = 0
var _lifetime_max_ticks: int = 0
var _logic_pos: Vector3


func add_bounce(additional_bounces: float) -> void:
	_stats.bounces_remaining += additional_bounces


func get_target() -> Entity:
	return _target


func get_source() -> Entity:
	return _source


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

	# Convert lifetime to ticks
	_lifetime_max_ticks = int(lifetime_max * TICKS_PER_SECOND)

	# Execute spawn callbacks
	for cb: Callable in _stats.on_spawn_callbacks:
		if cb.is_valid():
			cb.call({"projectile": self, "_source": _source, "_target": _target})


## Called by SpawnManager AFTER the projectile is in the scene tree and positioned.
## This ensures trajectory captures the correct global_position as start point.
func init_trajectory() -> void:
	_logic_pos = global_position
	if trajectory:
		trajectory = trajectory.duplicate()
		trajectory.init(self, _source, _target)
	else:
		Verbose.error("No trajectory assigned to projectile [" + name + "]", Verbose.Category.PROJECTILE)
		queue_free()


func process_tick() -> void:
	_life_ticks += 1
	if _life_ticks > _lifetime_max_ticks:
		queue_free()
		return
	
	var old_pos = _logic_pos
	if trajectory:
		_logic_pos = trajectory.update(_logic_pos, 1.0 / TICKS_PER_SECOND)
		global_position = _logic_pos.snapped(Vector3(0.01, 0.01, 0.01))
	
	_check_hit(old_pos, _logic_pos)


func _check_hit(p_from: Vector3, p_to: Vector3) -> void:
	if not is_instance_valid(_target): return
	if _target in _hit_history: return
	var target_pos: Vector3 = _target.get_collision_center() # T
	var segment: Vector3 = p_to - p_from # AB
	var segment_length_sq: float = segment.length_squared()
	var t: float = 0.0
	if segment_length_sq > 0:
		t = (target_pos - p_from).dot(segment) / segment_length_sq # P = t * AB (orthogonal projection)
		t = clamp(t, 0.0, 1.0) # Restrain to [AB]
	
	var closest_point = p_from + segment * t # P
	var dist_sq = closest_point.distance_squared_to(target_pos)
	
	if dist_sq <= HIT_DISTANCE_SQ:
		global_position = closest_point
		_on_hit(_target)


func _on_hit(hit_target: Entity) -> void:
	Verbose.trace("Hit: " + hit_target.name, Verbose.Category.PROJECTILE)
	_hit_history.append(hit_target)
	target_hit.emit(hit_target, global_position)
	
	# Execute all hit callbacks
	for cb: Callable in _stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				ProjectileStats.VarType.SOURCE: _source,
				ProjectileStats.VarType.TARGET: hit_target,
				ProjectileStats.VarType.PROJECTILE: self,
				ProjectileStats.VarType.POSITION: global_position
			})
	
	# Handle bouncing if remaining bounces
	if _stats.bounces_remaining >= 0 and Utils.is_randomize_modifier_active(_stats.bounces_remaining * 100, hit_target.battle_id):
		_handle_bounce(hit_target)
	else:
		# No more bounces, destroy projectile
		queue_free()


func retarget(new_target: Entity) -> void:
	if new_target == null or not is_instance_valid(new_target):
		return
	if _target and is_instance_valid(_target) and _target.died.is_connected(_on_target_died):
		_target.died.disconnect(_on_target_died)
	_target = new_target
	if _target.died and not _target.died.is_connected(_on_target_died):
		_target.died.connect(_on_target_died)
	if trajectory:
		trajectory.retarget(new_target)


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
		retarget(new_target)
	else:
		# No valid _target found, destroy projectile
		queue_free()


func _on_target_died() -> void:
	queue_free()
