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
	
	if _owner.status_module != null:
		_owner.status_module.stunned_changed.connect(_on_owner_stunned_changed)


func execute_auto_attack(target: Entity) -> bool:
	if not is_instance_valid(target):
		attack_completed.emit()
		return false
	
	if _owner.status_module.has_status(Status.Type.STUN):
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
	_pending_attacks.clear()
	_pending_melee_attacks.clear()
	_current_phase = AttackPhase.COOLDOWN
	
	if _animation_module != null:
		_animation_module.stop_attack_animation()
	
	attack_completed.emit()


func _prepare_projectile_stats() -> ProjectileStats:
	var projectile_stats := ProjectileStats.new()
	
	# Create damage callback
	var damage_modifiers_callbacks: Array[Callable]
	var additional_callbacks: Array[Callable]
	_consume_modifiers(damage_modifiers_callbacks, additional_callbacks)
	projectile_stats.on_hit_callbacks.append(func(data: Dictionary):
		var hit_target: Entity = data[ProjectileStats.VarType.TARGET]
		var hit_source: Entity = data[ProjectileStats.VarType.SOURCE]
		
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
		var damage: float = ( _owner.stats.attack_damage + add) * (mul / 100.0)
		var damage_done: float = 0
		if hit_source and hit_target:
			damage_done = hit_source.direct_damage(hit_target, damage, Utils.DamageType.PHYSICAL, &"auto_attack")
		
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


func _start_ranged_attack(target: Entity) -> void:
	var projectile_spawn: Node3D = _projectile_spawn if _projectile_spawn != null else _owner
	var projectile_stats: ProjectileStats = _prepare_projectile_stats()
	
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


func _start_melee_attack(target: Entity) -> void:
	var attack_stats: ProjectileStats = _prepare_projectile_stats()
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
				ProjectileStats.VarType.SOURCE: _owner,
				ProjectileStats.VarType.TARGET: target,
				ProjectileStats.VarType.PROJECTILE: null,
				ProjectileStats.VarType.POSITION: _owner.global_position
			})


func _consume_modifiers(damage_modifier_callbacks: Array[Callable], additional_callbacks: Array[Callable]) -> void:
	for aa_modifier: AutoAttackModifier in _owner.auto_attack_modifier_registry.consume_all_modifiers():
		if aa_modifier.additional_effect_callback.is_valid():
			additional_callbacks.append(aa_modifier.additional_effect_callback)
		if aa_modifier.damage_modifier_callback.is_valid():
			damage_modifier_callbacks.append(aa_modifier.damage_modifier_callback)


# ============================== Callbacks ==============================

func _on_animation_module_attack_hit_frame() -> void:
	# Called when animation reaches hit frame
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED:
			_on_ranged_animation_hit()
		EntityStats.AutoAttackType.MELEE:
			_on_melee_animation_hit()
	
	# Signal completion so module can restart cooldown
	_owner.auto_attack_completed.emit(_owner)


func _on_ranged_animation_hit() -> void:
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


func _on_melee_animation_hit() -> void:
	if _pending_melee_attacks.is_empty():
		return
	
	var melee_data: Dictionary = _pending_melee_attacks.pop_front()
	_process_melee_hit(melee_data)


func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		_cancel_attack()
