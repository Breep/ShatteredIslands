class_name AutoAttackModule
extends Module

# ============================== Enums ==============================

enum AttackPhase {
	COOLDOWN, # Waiting for cooldown before next attack
	ATTACKING # Attack in progress, waiting for completion
}

# ============================== Signals ==============================

signal attack_done()
signal target_changed(new_target: Entity)

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

#var _forced_target: Entity # TODO Unused now, maybe for a futur hero that can taunt ?
var _attack_strategy: TargetModule.TargettingStrategy = TargetModule.TargettingStrategy.RANDOM_ENEMY # The algo used to find the target

var _current_phase: AttackPhase = AttackPhase.COOLDOWN

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
	
	# Configure timer as one-shot
	_auto_attack_timer.one_shot = true

# ============================== Public functions ==============================

func start() -> void:
	attack_speed = _owner.stats.attack_speed
	_auto_attack_timer.start()


func stop() -> void:
	_auto_attack_timer.stop()


func prepare_projectile_stats() -> ProjectileStats:
	var projectile_stats := ProjectileStats.new()
	
	# Store damage value for callback
	var physical_damage := _owner.stats.attack_damage
	
	# Create damage callback
	projectile_stats.on_hit_callbacks.append(func(data: Dictionary):
		var hit_target: Entity = data[AutoAttackModifier.VarType.TARGET]
		var hit_source: Entity = data[AutoAttackModifier.VarType.SOURCE]
		if hit_source and hit_target:
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


func _auto_attack(target: Entity) -> void:
	_current_phase = AttackPhase.ATTACKING
	_owner.auto_attack(target)


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

func _on_auto_attack_timer_timeout() -> void:
	# Only launch attack if we're in COOLDOWN phase
	if _current_phase != AttackPhase.COOLDOWN:
		return
	
	var target = _owner.target_module.get_target(_attack_strategy)
	current_target = target
	if target == null:
		# No target, restart cooldown timer
		_auto_attack_timer.start()
		return
	
	_auto_attack(target)


func _on_owner_stats_attack_speed_changed(new_attack_speed: float) -> void:
	attack_speed = new_attack_speed


func _on_owner_died(_unused) -> void:
	stop()


func _on_owner_auto_attack_completed() -> void:
	# Attack is complete, return to COOLDOWN phase and restart timer
	if _current_phase == AttackPhase.ATTACKING:
		_current_phase = AttackPhase.COOLDOWN
		attack_done.emit()
		_auto_attack_timer.start()
