class_name AutoAttackModule
extends Module

# ============================== Signals ==============================

signal attack_done()
signal target_changed(new_target: Entity)

# ============================== Export variables ==============================

@export var _projectile_spawn: SpawnPoint
@export var _attack_manager: AttackManager

# ============================== OTHER variables ==============================

var attack_speed: float:
	get: return _attack_speed
	set(value):
		_attack_speed = value
		_set_auto_attack_speed(_attack_speed)

# ============================== Private variables ==============================

#var _forced_target: Character # TODO Unused now, maybe for a futur hero that can taunt ?
var _attack_strategy: TargetModule.TargettingStrategy = TargetModule.TargettingStrategy.CLOSEST_ENEMY # The algo used to find the target

var _attack_speed: float = 1 # Basic attack speed of the auto-attack module (attacks/s)

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
	_owner.stats.attack_speed_changed.connect(_on_owner_stats_attack_speed_changed)
	_owner.dead.connect(_on_owner_dead)

# ============================== Public functions ==============================

func start() -> void:
	attack_speed = _owner.stats.attack_speed
	_auto_attack_timer.start()


func stop() -> void:
	_auto_attack_timer.stop()

# ============================== Private functions ==============================

func _set_auto_attack_speed(new_attack_speed: float) -> void:
	if new_attack_speed <= 0:
		printerr("AutoAttackManager: Attack speed is lower than 0 ! [", get_path(), "]")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / new_attack_speed


func _auto_attack(target: Character) -> void:
	if _attack_manager != null:
		_attack_manager.attack(target, _projectile_spawn)
	else:
		var projectile_stats := ProjectileStats.new()
		projectile_stats.physical_damage_flat = _owner.stats.attack_damage
		projectile_stats.speed = 15
		_owner.projectile_attack(target, Projectile.ProjectileType.AUTO_ATTACK, _projectile_spawn, projectile_stats)
	
	attack_done.emit()

# ============================== Callbacks functions ==============================

func _on_auto_attack_timer_timeout() -> void:
	var target = _owner.target_module.get_target(_attack_strategy)
	current_target = target
	if target == null: return
	_auto_attack(target)


func _on_owner_stats_attack_speed_changed(new_attack_speed: float) -> void:
	attack_speed = new_attack_speed


func _on_owner_dead(_unused) -> void:
	stop()


















 
