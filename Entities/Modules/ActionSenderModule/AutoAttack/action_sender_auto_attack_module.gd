class_name ActionSenderAutoAttackModule
extends ActionSenderModule

# ============================== Enums ==============================

enum AttackPhase {
	COOLDOWN, # Waiting for cooldown before next attack
	APPROACHING, # Moving towards target
	ATTACKING # Attack in progress — tick counter running
}

enum ActiveAttackVar {
	TARGET,
	PROJECTILE_TYPE,
	SPAWN_NODE,
	STATS,
	DAMAGE_MODIFIER_CALLBACKS,
	ADDITIONAL_CALLBACKS,
}

# ============================== Signals ==============================

signal attack_started(lock_seconds: float) # Notify animation (visual only)
signal attack_completed() # Attack cycle complete, ready for next attack

# ============================== Constants ==============================

const TICKS_PER_SECOND: int = 60
const IMPACT_RATIO: float = 0.4 # 40% of interval — tick where damage/projectile fires
const LOCK_RATIO: float = 0.8 # 80% of interval — tick where animation ends

# ============================== Export variables ==============================

@export var _projectile_spawn: Node3D

# ============================== Private variables ==============================

var _current_phase: AttackPhase = AttackPhase.COOLDOWN

# Module references (set via connect_modules)
var _movement_module: MovementModule = null
var _animation_module = null # AnimationModule, but no typing to avoid circular dependency

# Approach management
var _is_approaching: bool = false
var _approach_target: Entity = null

# Tick-based attack timing (deterministic)
var _ticks_since_attack_start: int = 0
var _impact_tick: int = 0
var _lock_ticks: int = 0
var _impact_applied: bool = false

# Active attack data (replaces _pending_attacks / _pending_melee_attacks)
var _active_attack_data: Dictionary = {}

var _projectile_type: Projectile.Type = Projectile.Type.SHADOW_BOLT

# ============================== Public functions ==============================

func connect_modules(movement_module: MovementModule, animation_module: AnimationModule) -> void:
	_movement_module = movement_module
	_animation_module = animation_module
	# NOTE: No longer connecting to attack_hit_frame — logic is now tick-driven
	
	if _owner.alterations_module != null:
		_owner.alterations_module.stunned_changed.connect(_on_owner_stunned_changed)


func set_auto_attack_spawn(projectile_spawn: Marker3D) -> void:
	_projectile_spawn = projectile_spawn
	

func set_projectile_type(projectile_type: Projectile.Type) -> void:
	_projectile_type = projectile_type

## Called every tick by AutoAttackPeriodicModule.process_tick() — advances attack counters.
func process_tick() -> void:
	if _current_phase != AttackPhase.ATTACKING:
		return
	
	_ticks_since_attack_start += 1
	
	# Impact tick — apply damage / spawn projectile
	if not _impact_applied and _ticks_since_attack_start >= _impact_tick:
		_impact_applied = true
		_execute_attack_impact()
	
	# Lock tick — attack phase complete
	if _ticks_since_attack_start >= _lock_ticks:
		_current_phase = AttackPhase.COOLDOWN
		_active_attack_data.clear()
		_owner.auto_attack_completed.emit(_owner)
		attack_completed.emit()


func execute_auto_attack(target: Entity) -> bool:
	if not is_instance_valid(target):
		attack_completed.emit()
		return false
	
	if _owner.alterations_module.has_status(Status.Type.STUN):
		attack_completed.emit()
		return false
	
	if not _check_range_and_approach(target):
		return false # Out of range, approach started or failed
	
	if _owner != null:
		_owner.look_at_target_y_only(target.global_position)
	
	_current_phase = AttackPhase.ATTACKING
	
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED: _start_ranged_attack(target)
		EntityStats.AutoAttackType.MELEE: _start_melee_attack(target)
	
	return true


func _cancel_attack() -> void:
	stop_approaching()
	_active_attack_data.clear()
	_ticks_since_attack_start = 0
	_impact_applied = false
	_current_phase = AttackPhase.COOLDOWN
	
	if _animation_module != null:
		_animation_module.stop_attack_animation()
	
	attack_completed.emit()


func is_attacking() -> bool:
	return _current_phase == AttackPhase.ATTACKING


func is_approaching() -> bool:
	return _is_approaching


func get_approach_target() -> Entity:
	return _approach_target


func stop_approaching() -> void:
	if _is_approaching and _movement_module != null:
		_movement_module.stop_following()
	_is_approaching = false
	_approach_target = null
	_current_phase = AttackPhase.COOLDOWN


# ============================== Private functions ==============================

func _calculate_attack_timings(interval_ticks: int) -> void:
	_impact_tick = maxi(1, int(interval_ticks * IMPACT_RATIO))
	_lock_ticks = maxi(_impact_tick + 1, int(interval_ticks * LOCK_RATIO))


func _start_attack_tick_counter(interval_ticks: int) -> void:
	_ticks_since_attack_start = 0
	_impact_applied = false
	_calculate_attack_timings(interval_ticks)
	
	# Calculate lock duration in seconds for animation sync
	var lock_seconds: float = float(_lock_ticks) / float(TICKS_PER_SECOND)
	attack_started.emit(lock_seconds)


func _check_range_and_approach(target: Entity) -> bool:
	var distance: float = _owner.global_position.distance_to(target.global_position)
	
	# Infinite range (attack_range <= 0) - always in range
	if _owner.stats.attack_range <= 0:
		return true
	
	# In range - can attack
	if distance <= _owner.stats.attack_range:
		return true
	
	# Out of range - try to approach
	if _movement_module != null:
		_is_approaching = true
		_approach_target = target
		_current_phase = AttackPhase.APPROACHING
		_movement_module.follow_entity(target)
		Verbose.debug("AutoAttackModule: Starting approach to target", Verbose.Category.ENTITY_MODULE)
		return false
	
	# No movement module (fixed turret) - fail attack
	Verbose.debug("AutoAttackModule: Target out of range, no movement module", Verbose.Category.ENTITY_MODULE)
	attack_completed.emit()
	return false


func _start_ranged_attack(target: Entity) -> void:
	var projectile_spawn: Node3D = _projectile_spawn if _projectile_spawn != null else _owner
	var projectile_stats: ProjectileStats = _prepare_projectile_stats()
	
	var attack_cmd = AttackCommand.new().setup(
		target,
		_projectile_type,
		projectile_spawn,
		projectile_stats
	)
	
	if attack_cmd == null:
		Verbose.error("Can't create AttackCommand for ranged attack", Verbose.Category.ENTITY_MODULE)
		attack_completed.emit()
		return
	
	# Store active attack data
	_active_attack_data = {
		ActiveAttackVar.TARGET: attack_cmd.target,
		ActiveAttackVar.PROJECTILE_TYPE: attack_cmd.projectile_type,
		ActiveAttackVar.SPAWN_NODE: attack_cmd.spawn_node,
		ActiveAttackVar.STATS: attack_cmd.stats,
	}
	
	# Calculate interval from current attack speed
	var interval_ticks: int = _get_attack_interval_ticks()
	_start_attack_tick_counter(interval_ticks)


func _start_melee_attack(target: Entity) -> void:
	var attack_stats: ProjectileStats = _prepare_projectile_stats()
	
	# Store active attack data
	_active_attack_data = {
		ActiveAttackVar.TARGET: target,
		ActiveAttackVar.STATS: attack_stats,
	}
	
	# Calculate interval from current attack speed
	var interval_ticks: int = _get_attack_interval_ticks()
	_start_attack_tick_counter(interval_ticks)


func _execute_attack_impact() -> void:
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED:
			_execute_ranged_impact()
		EntityStats.AutoAttackType.MELEE:
			_execute_melee_impact()


func _execute_ranged_impact() -> void:
	if _active_attack_data.is_empty():
		return

	var target_ref = _active_attack_data.get(ActiveAttackVar.TARGET)
	if not is_instance_valid(target_ref) or target_ref.is_queued_for_deletion():
		return

	var target: Entity = target_ref
	var projectile_type: Projectile.Type = _active_attack_data.get(ActiveAttackVar.PROJECTILE_TYPE)
	var spawn_node: Node3D = _active_attack_data.get(ActiveAttackVar.SPAWN_NODE)
	var stats: ProjectileStats = _active_attack_data.get(ActiveAttackVar.STATS)

	_owner.projectile_attack(
		target,
		projectile_type,
		spawn_node,
		stats,
		true
	)


func _execute_melee_impact() -> void:
	if _active_attack_data.is_empty():
		return

	var target_ref = _active_attack_data.get(ActiveAttackVar.TARGET)
	if not is_instance_valid(target_ref) or target_ref.is_queued_for_deletion():
		return

	var target: Entity = target_ref
	var stats: ProjectileStats = _active_attack_data.get(ActiveAttackVar.STATS)
	
	# Execute all on-hit callbacks
	for cb: Callable in stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				ProjectileStats.VarType.SOURCE: _owner,
				ProjectileStats.VarType.TARGET: target,
				ProjectileStats.VarType.PROJECTILE: null,
				ProjectileStats.VarType.POSITION: _owner.global_position
			})


func _get_attack_interval_ticks() -> int:
	var attack_speed: float = _owner.stats.attack_speed
	if attack_speed <= 0:
		return TICKS_PER_SECOND # fallback 1 attack/sec
	return maxi(1, int(TICKS_PER_SECOND / attack_speed))


func _prepare_projectile_stats() -> ProjectileStats:
	var projectile_stats := ProjectileStats.new()
	
	# Create damage callback
	var damage_modifiers_callbacks: Array[Callable]
	var additional_callbacks: Array[Callable]
	_consume_modifiers(damage_modifiers_callbacks, additional_callbacks)
	projectile_stats.on_hit_callbacks.append(func(data: Dictionary):
		var hit_target = data[ProjectileStats.VarType.TARGET]
		var hit_source = data[ProjectileStats.VarType.SOURCE]
		
		var mod = {
			AutoAttackModifier.VarType.SOURCE: hit_source,
			AutoAttackModifier.VarType.TARGET: hit_target,
			AutoAttackModifier.VarType.DAMAGE_ADD: 0,
			AutoAttackModifier.VarType.DAMAGE_MUL: 100,
		}
		for damage_modifiers_callback in damage_modifiers_callbacks:
			damage_modifiers_callback.call(mod)
		
		var add: float = mod[AutoAttackModifier.VarType.DAMAGE_ADD]
		var mul: float = mod[AutoAttackModifier.VarType.DAMAGE_MUL]
		var damage: float = (_owner.stats.attack_damage + add) * (mul / 100.0)
		var damage_done: float = 0
		if hit_source and hit_target:
			damage_done = hit_source.direct_damage(hit_target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"auto_attack")
		
		for additional_callback in additional_callbacks:
			additional_callback.call({
				AutoAttackModifier.VarType.SOURCE: hit_source,
				AutoAttackModifier.VarType.TARGET: hit_target,
				AutoAttackModifier.VarType.POSITION: data[ProjectileStats.VarType.POSITION],
				AutoAttackModifier.VarType.DAMAGE: damage_done,
				AutoAttackModifier.VarType.PROJECTILE: data[ProjectileStats.VarType.PROJECTILE],
			})
	)
	
	return projectile_stats


func _consume_modifiers(damage_modifier_callbacks: Array[Callable], additional_callbacks: Array[Callable]) -> void:
	for aa_modifier: AutoAttackModifier in _owner.auto_attack_modifier_registry.consume_all_modifiers():
		if aa_modifier.additional_effect_callback.is_valid():
			additional_callbacks.append(aa_modifier.additional_effect_callback)
		if aa_modifier.damage_modifier_callback.is_valid():
			damage_modifier_callbacks.append(aa_modifier.damage_modifier_callback)


# ============================== Callbacks ==============================

func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		_cancel_attack()
