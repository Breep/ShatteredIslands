class_name AutoAttackModule
extends Module

# ============================== Export variables ==============================

@export var projectile_spawn: Node3D

var attack_speed: float:
	get: return _attack_speed
	set(value):
		_attack_speed = value
		set_auto_attack_speed(_attack_speed)

# ============================== Private variables ==============================

var _aa_stats: CharacterAutoAttackStats # Ref to the owner auto attack stats

var _projectile_type: Projectile.ProjectileType

#var _forced_target: Character # TODO Unused now, maybe for a futur hero that can taunt ?
var _attack_strategy: TargetManager.TargettingStrategy = TargetManager.TargettingStrategy.CLOSEST_ENEMY # The algo used to find the target

var _default_attack_speed: float # Default attack speed of the hero

var _action_module: ActionModule

var _damage: int # Basic damage of the auto-attack module
var _attack_speed: float = 1 # Basic attack speed of the auto-attack module (attacks/s)

# ============================== Local scene nodes ==============================

@onready var _auto_attack_timer: Timer = %AutoAttackTimer

# ============================== Public functions ==============================

func start() -> void:
	attack_speed = _source.stats.attack_speed
	_auto_attack_timer.start()


func stop() -> void:
	_auto_attack_timer.stop()


func set_projectile(projectile_type: Projectile.ProjectileType) -> void:
	_projectile_type = projectile_type

# ============================== Private functions ==============================

func _specific_init() -> void:
	var action_modules = _source.find_children("", "ActionModule", true, false)
	if action_modules.is_empty():
		printerr("AutoAttackModule: An ActionModule is mandatory on the owner")
		return
	
	_action_module = action_modules[0]
	_source.stats.attack_speed_changed.connect(_on_source_stats_attack_speed_changed)


func set_auto_attack_speed(attack_speed: float) -> void:
	if attack_speed <= 0:
		printerr("AutoAttackManager: Attack speed is lower than 0 !")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / attack_speed


func _auto_attack(target: Character) -> void:
	var projectile_stats := ProjectileStats.new()
	
	projectile_stats.physical_damage_flat = _source.stats.attack_damage
	projectile_stats.speed = 10
	
	if _attack_manager != null:
		_attack_manager.notice_auto_attack_done(target)
		_attack_manager.update_aa_projectile_stats(projectile_stats)
	
	_action_module.projectile_attack(target, _projectile_type, projectile_spawn, projectile_stats)


func _update_auto_attack_speed() -> void:
	_source.stats.attack_speed = _default_attack_speed
	var attack_speed_boost: float = _aa_stats.attack_speed_boost + _aa_stats.attack_speed_overtime_current
	var multiply_boost: float = remap(attack_speed_boost, 0, 100, 1, 2) # Convert % in proportional multiple (100% = x2 | 150% = x2.5)
	_source.stats.attack_speed *= multiply_boost
	set_auto_attack_speed(_source.stats.attack_speed)

# ============================== Callbacks functions ==============================

func _on_auto_attack_timer_timeout() -> void:
	var target = _source.target_manager.get_target(_attack_strategy)
	if target == null: return
	_auto_attack(target)


func _on_source_stats_attack_speed_changed(new_attack_speed: float) -> void:
	attack_speed = new_attack_speed



















 
