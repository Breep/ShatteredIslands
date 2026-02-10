class_name ActionSenderAutoAttackModule
extends ActionSenderModule

# ============================== Enums ==============================

enum AttackPhase {
	COOLDOWN, # Waiting for cooldown before next attack
	APPROACHING, # Moving towards target
	ATTACKING # Attack in progress, waiting for completion
}

# ============================== Signals ==============================

signal attack_started() # Animation started
signal attack_completed() # Attack cycle complete, ready for next attack

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

# Pending attacks (for animations)
var _pending_attacks: Array = [] # Array of AttackCommand
var _pending_melee_attacks: Array = [] # Array of melee attack data

# ============================== Public functions ==============================

func connect_modules(movement_module: MovementModule, animation_module: AnimationModule) -> void:
	_movement_module = movement_module
	_animation_module = animation_module
	
	# Connect to AnimationModule hit frame signal
	if _animation_module != null:
		_animation_module.attack_hit_frame.connect(_on_animation_module_attack_hit_frame)


func execute_auto_attack(target: Entity) -> void:
	if target == null:
		Verbose.warn("execute_auto_attack: No target", Verbose.Category.ENTITY_MODULE)
		attack_completed.emit()
		return
	
	# Check range and possibly start approaching
	if not _check_range_and_approach(target):
		return # Out of range, approach started or failed
	
	# Look at target
	if _owner != null:
		_owner.look_at_target_y_only(target.global_position)
	
	_current_phase = AttackPhase.ATTACKING
	
	# Dispatch to correct attack type
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED: _execute_ranged_attack(target)
		EntityStats.AutoAttackType.MELEE: _execute_melee_attack(target)


func on_ranged_animation_hit() -> void:
	if _pending_attacks.is_empty():
		return
	
	var attack_cmd = _pending_attacks.pop_front()
	_owner.projectile_attack(
		attack_cmd.target,
		attack_cmd.projectile_type,
		attack_cmd.spawn_node,
		attack_cmd.stats,
		true
	)


func on_melee_animation_hit() -> void:
	if _pending_melee_attacks.is_empty():
		return
	
	var melee_data: Dictionary = _pending_melee_attacks.pop_front()
	_process_melee_hit(melee_data)


func prepare_projectile_stats() -> ProjectileStats:
	var projectile_stats := ProjectileStats.new()
	
	# Store damage value for callback
	var physical_damage: float = _owner.stats.attack_damage
	
	# Create damage callback
	projectile_stats.on_hit_callbacks.append(func(data: Dictionary):
		var hit_target: Entity = data[AutoAttackModifier.VarType.TARGET]
		var hit_source: Entity = data[AutoAttackModifier.VarType.SOURCE]
		if hit_source and hit_target:
			hit_source.direct_damage(hit_target, physical_damage, Utils.DamageType.PHYSICAL, &"auto_attack")
	)
	
	_consume_modifiers(projectile_stats)
	return projectile_stats


func get_current_phase() -> AttackPhase:
	return _current_phase


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


func _execute_ranged_attack(target: Entity) -> void:
	var projectile_spawn: Node3D = _projectile_spawn if _projectile_spawn != null else _owner
	var projectile_stats: ProjectileStats = prepare_projectile_stats()
	
	var attack_cmd = AttackCommand.new().setup(
		target,
		Projectile.Type.SHADOW_BOLT,
		projectile_spawn,
		projectile_stats
	)
	
	if attack_cmd == null:
		Verbose.error("Can't create AttackCommand for ranged attack", Verbose.Category.ENTITY_MODULE)
		attack_completed.emit()
		return
	
	if _animation_module != null:
		if _pending_attacks.is_empty():
			_pending_attacks.append(attack_cmd)
		else:
			_pending_attacks[0] = attack_cmd
		attack_started.emit()
	else:
		_owner.projectile_attack(
			attack_cmd.target,
			attack_cmd.projectile_type,
			attack_cmd.spawn_node,
			attack_cmd.stats,
			true
		)
		_owner.auto_attack_completed.emit(_owner)
		attack_completed.emit()


func _execute_melee_attack(target: Entity) -> void:
	var attack_stats: ProjectileStats = prepare_projectile_stats()
	var melee_data := {
		"target": target,
		"stats": attack_stats
	}
	
	if _animation_module != null:
		if _pending_melee_attacks.is_empty():
			_pending_melee_attacks.append(melee_data)
		else:
			_pending_melee_attacks[0] = melee_data
		attack_started.emit()
	else:
		# No animation, execute immediately
		_process_melee_hit(melee_data)
		_owner.auto_attack_completed.emit(_owner)
		attack_completed.emit()


func _process_melee_hit(melee_data: Dictionary) -> void:
	var target: Entity = melee_data.get("target")
	var stats: ProjectileStats = melee_data.get("stats")
	
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		return
	
	# Execute all on-hit callbacks
	for cb: Callable in stats.on_hit_callbacks:
		if cb.is_valid():
			cb.call({
				AutoAttackModifier.VarType.SOURCE: _owner,
				AutoAttackModifier.VarType.TARGET: target,
				AutoAttackModifier.VarType.PROJECTILE: null,
				AutoAttackModifier.VarType.POSITION: _owner.global_position
			})


func _consume_modifiers(projectile_stats: ProjectileStats) -> void:
	for aa_modifier: AutoAttackModifier in _owner.auto_attack_modifier_registry.consume_all_modifiers():
		# Execute on-attack callbacks
		if aa_modifier.on_attack_logic_callback.is_valid():
			aa_modifier.on_attack_logic_callback.call({})
		if aa_modifier.on_attack_visual_callback.is_valid():
			aa_modifier.on_attack_visual_callback.call({})
		
		# Add on-hit callbacks to projectile
		if aa_modifier.on_hit_logic_callback.is_valid():
			projectile_stats.on_hit_callbacks.append(aa_modifier.on_hit_logic_callback)
		if aa_modifier.on_hit_visual_callback.is_valid():
			projectile_stats.on_hit_callbacks.append(aa_modifier.on_hit_visual_callback)


# ============================== Callbacks ==============================

func _on_animation_module_attack_hit_frame() -> void:
	# Called when animation reaches hit frame
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED:
			on_ranged_animation_hit()
		EntityStats.AutoAttackType.MELEE:
			on_melee_animation_hit()
	
	# Signal completion so module can restart cooldown
	_owner.auto_attack_completed.emit(_owner)
