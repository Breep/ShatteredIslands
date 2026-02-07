class_name AutoAttackModule
extends Module

# ============================== Enums ==============================

enum AttackPhase {
	COOLDOWN,     # Waiting for cooldown before next attack
	APPROACHING,  # Moving towards target
	ATTACKING     # Attack in progress, waiting for completion
}

enum AttackType {
	MELEE,
	RANGED
}

# ============================== Signals ==============================

signal target_changed(new_target: Entity)
signal attack_started()  # Animation started
signal attack_completed()  # Attack cycle complete, ready for next attack

# ============================== Export variables ==============================

@export var _projectile_spawn: Node3D

# ============================== Public variables ==============================

var _attack_speed: float = 1.0 # Basic attack speed of the auto-attack module (attacks/s)
var attack_speed: float:
	get: return _attack_speed
	set(value):
		if _attack_speed == value: return
		_attack_speed = value
		_set_auto_attack_speed(_attack_speed)

# ============================== Private variables ==============================

var _attack_strategy: TargetModule.TargettingStrategy = TargetModule.TargettingStrategy.RANDOM_ENEMY
var _current_phase: AttackPhase = AttackPhase.COOLDOWN

# Module references (optional)
var _movement_module: MovementModule = null
var _action_module: ActionModule = null
var _animation_module = null  # AnimationModule, but no typing to avoid circular dependency

# Approach management
var _is_approaching: bool = false
var _approach_target: Entity = null

# Pending attacks (for animations)
var _pending_attacks: Array = []  # Array of AttackCommand
var _pending_melee_attacks: Array = []  # Array of melee attack data

var _current_target: Entity
var current_target: Entity:
	get: return _current_target
	set(value):
		if current_target != value:
			target_changed.emit(value)
			_current_target = value

# ============================== Local scene nodes ==============================

@onready var _auto_attack_timer: Timer = %AutoAttackTimer

# ============================== Node base function ==============================

func _ready() -> void:
	if _owner == null:
		Verbose.error("Auto attack module needs an owner (Entity)", Verbose.Category.ENTITY_MODULE)
		return
	
	if _projectile_spawn == null:
		_projectile_spawn = _owner
	
	_owner.stats.attack_speed_changed.connect(_on_owner_stats_attack_speed_changed)
	_owner.died.connect(_on_owner_died)
	_owner.auto_attack_completed.connect(_on_owner_auto_attack_completed)
	
	_auto_attack_timer.one_shot = true


func connect_modules(movement_module: MovementModule, action_module: ActionModule, animation_module: AnimationModule) -> void:
	_movement_module = movement_module
	_action_module = action_module
	_animation_module = animation_module
	
	# Connect to AnimationModule hit frame signal
	if _animation_module != null:
		_animation_module.attack_hit_frame.connect(_on_animation_module_attack_hit_frame)

# ============================== Public functions ==============================

func start() -> void:
	Verbose.debug("Auto attack module started for " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
	attack_speed = _owner.stats.attack_speed
	_auto_attack_timer.start()


func stop() -> void:
	Verbose.debug("Auto attack module stopped for " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
	_auto_attack_timer.stop()


func on_ranged_animation_hit() -> void:
	if _pending_attacks.is_empty():
		return
	
	var attack_cmd = _pending_attacks.pop_front()
	if _action_module != null:
		_action_module.projectile_attack(
			attack_cmd.target,
			attack_cmd.projectile_type,
			attack_cmd.spawn_node,
			attack_cmd.stats
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
			print("Auto attack hit target: ", hit_target.entity_name)
			hit_source.direct_damage(hit_target, physical_damage, Utils.DamageType.PHYSICAL, &"auto_attack")
	)
	
	_consume_modifiers(projectile_stats)
	return projectile_stats

# ============================== Private functions ==============================

func _set_auto_attack_speed(new_attack_speed: float) -> void:
	if new_attack_speed <= 0:
		printerr("AutoAttackManager: Attack speed is lower than 0 ! [", get_path(), "]")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / new_attack_speed


func execute_auto_attack(target: Entity) -> void:
	if target == null:
		Verbose.warn("execute_auto_attack: No target", Verbose.Category.ENTITY_MODULE)
		attack_completed.emit()
		return
	
	# Check range and possibly start approaching
	if not _check_range_and_approach(target):
		return  # Out of range, approach started or failed
	
	# Look at target
	if _owner != null:
		_owner.look_at_target_y_only(target.global_position)
	
	# Dispatch to correct attack type
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED: _execute_ranged_attack(target)
		EntityStats.AutoAttackType.MELEE: _execute_melee_attack(target)


func _execute_ranged_attack(target: Entity) -> void:
	if _action_module == null:
		Verbose.error("No ActionModule available for ranged attack", Verbose.Category.ENTITY_MODULE)
		attack_completed.emit()
		return
	
	var projectile_spawn: Node3D = _projectile_spawn if _projectile_spawn != null else _owner
	var projectile_stats: ProjectileStats = prepare_projectile_stats()
	
	var attack_cmd = _action_module.build_projectile_attack(
		target,
		Projectile.Type.SHADOW_BOLT,
		projectile_spawn,
		projectile_stats
	)
	
	if attack_cmd == null:
		Verbose.error("Can't create AttackCommand for ranged attack", Verbose.Category.ENTITY_MODULE)
		attack_completed.emit()
		return
	
	# If has animation module, delay projectile spawn until animation hits
	if _animation_module != null:
		# Store pending attack (replace if one already exists)
		if _pending_attacks.is_empty():
			_pending_attacks.append(attack_cmd)
		else:
			_pending_attacks[0] = attack_cmd
		attack_started.emit()
	else:
		# No animation, spawn projectile immediately
		_action_module.projectile_attack(
			attack_cmd.target,
			attack_cmd.projectile_type,
			attack_cmd.spawn_node,
			attack_cmd.stats
		)
		attack_completed.emit()


func _execute_melee_attack(target: Entity) -> void:
	var attack_stats: ProjectileStats = prepare_projectile_stats()
	var melee_data := {
		"target": target,
		"stats": attack_stats
	}
	
	# If has animation module, delay execution until animation hits
	if _animation_module != null:
		# Store pending melee attack (replace if one already exists)
		if _pending_melee_attacks.is_empty():
			_pending_melee_attacks.append(melee_data)
		else:
			_pending_melee_attacks[0] = melee_data
		attack_started.emit()
	else:
		# No animation, execute immediately
		_process_melee_hit(melee_data)
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


func _auto_attack(target: Entity) -> void:
	_current_phase = AttackPhase.ATTACKING
	execute_auto_attack(target)


func _check_range_and_approach(target: Entity) -> bool:
	var distance: float = _owner.global_position.distance_to(target.global_position)
	
	# In range - can attack
	if distance <= _owner.stats.attack_range:
		return true
	
	# Out of range - try to approach
	if _movement_module != null:
		_is_approaching = true
		_approach_target = target
		_current_phase = AttackPhase.APPROACHING
		_movement_module.follow_entity(target)
		_auto_attack_timer.stop()  # Stop timer during approach
		Verbose.debug("AutoAttackModule: Starting approach to target", Verbose.Category.ENTITY_MODULE)
		return false
	
	# No movement module (fixed turret) - fail attack
	Verbose.debug("AutoAttackModule: Target out of range, no movement module", Verbose.Category.ENTITY_MODULE)
	attack_completed.emit()
	return false


func _stop_approaching() -> void:
	if _is_approaching and _movement_module != null:
		_movement_module.stop_following()
	_is_approaching = false
	_approach_target = null
	_current_phase = AttackPhase.COOLDOWN


func _process(_delta: float) -> void:
	# Quick and dirty: check distance during approach
	# TODO: Replace with Area3D detection + signal
	if _is_approaching and _approach_target != null:
		# Check if target still valid
		if not is_instance_valid(_approach_target) or _approach_target.is_dead():
			_stop_approaching()
			_auto_attack_timer.start()
			return
		
		# Check if now in range
		var distance: float = _owner.global_position.distance_to(_approach_target.global_position)
		if distance <= _owner.stats.attack_range:
			# In range! Stop approach and attack
			var target_to_attack: Entity = _approach_target
			_stop_approaching()
			execute_auto_attack(target_to_attack)
			_auto_attack_timer.start()


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

# ============================== Callbacks functions ==============================

func _on_animation_module_attack_hit_frame() -> void:
	# Called when animation reaches hit frame
	match _owner.stats.auto_attack_type:
		EntityStats.AutoAttackType.RANGED:
			on_ranged_animation_hit()
		EntityStats.AutoAttackType.MELEE:
			on_melee_animation_hit()
	
	# Signal completion so module can restart cooldown
	_owner.auto_attack_completed.emit(_owner)


func _on_auto_attack_timer_timeout() -> void:
	if not is_instance_valid(_owner):
		return
	
	var target: Entity = _owner.target_module.get_target(_attack_strategy)
	if target == null:
		return
	
	_auto_attack(target)


func _on_owner_stats_attack_speed_changed(new_attack_speed: float) -> void:
	attack_speed = new_attack_speed


func _on_owner_died(_unused) -> void:
	stop()


func _on_owner_auto_attack_completed() -> void:
	# Attack attempt complete (successful or not), restart timer
	_current_phase = AttackPhase.COOLDOWN
	attack_completed.emit()
	_auto_attack_timer.start()
