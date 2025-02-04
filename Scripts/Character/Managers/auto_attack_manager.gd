class_name AutoAttackManager
extends Node

# ============================== Signals ==============================

signal armor_gained(armor_stacks: int)
signal max_health_gained(health_amount: int)
signal heal_ally_triggered(heal_amount: int)

# ============================== Export variables ==============================

@export var projectile_spawn: Node3D

# ============================== Public variables ==============================

var aa_counter: int = 0 # Counter of auto attacks

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _aa_stats: CharacterAutoAttackStats # Ref to the owner auto attack stats
var _projectile_scene: PackedScene # Ref to the AutoAttackProjectile packed scene
#var _forced_target: Character # TODO Unused now, maybe for a futur hero that can taunt ?
var _attack_strategy: TargetManager.TargettingStrategy = TargetManager.TargettingStrategy.CLOSEST_ENEMY # The algo used to find the target

# ============================== Local scene nodes ==============================

@onready var _auto_attack_timer: Timer = %AutoAttackTimer

# ============================== Public functions ==============================

func start(source: Character, aa_stats: CharacterAutoAttackStats, projectile_scene: PackedScene) -> void:
	print("AutoAttackManager: Starting")
	if source == null:
		printerr("AutoAttackManager: source undef")
		return
	if aa_stats == null:
		printerr("AutoAttackManager: aa_stats undef")
		return
	if projectile_scene == null:
		printerr("AutoAttackManager: projectile_scene undef")
		return
	if projectile_spawn == null:
		printerr("AutoAttackManager: projectile_spawn undef")
		return
	
	_source = source
	_projectile_scene = projectile_scene
	_aa_stats = aa_stats
	set_auto_attack_speed(_aa_stats.attack_speed)
	_auto_attack_timer.start()


func stop() -> void:
	print("AutoAttackManager: Stopping")
	_auto_attack_timer.stop()


func set_auto_attack_speed(attack_speed: float) -> void:
	if attack_speed <= 0:
		printerr("AutoAttackManager: Attack speed is lower than 0 !")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / attack_speed

# ============================== Private functions ==============================

func _auto_attack(target: Character):
	aa_counter += 1
	
	# Fire sword
	if _aa_stats.fire_attack_activated:
		if aa_counter % _aa_stats.fire_attack_period == 0:
			_aa_stats.fire_attack_triggered = true
	
	# Necrosis scythe
	if _aa_stats.increase_max_hp_activated:
		if aa_counter % _aa_stats.increase_max_hp_period == 0:
			max_health_gained.emit(_aa_stats.increase_max_hp_amount)
	
	# Sword armor
	if Utils.is_randomize_modifier_active(_aa_stats.armor_stacks_chance):
		armor_gained.emit(_aa_stats.armor_stacks_amount)
	
	# Knife of terror
	if Utils.is_randomize_modifier_active(_aa_stats.healing_attack_chance):
		heal_ally_triggered.emit(_aa_stats.healing_attack_heal_amount)
	
	_spawn_projectile(target)
	_aa_stats.fire_attack_triggered = false


func _spawn_projectile(target: Character) -> void:
	var projectile: AutoAttackProjectile = _projectile_scene.instantiate()
	projectile.init(_source, target, _aa_stats)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position + Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))

# ============================== Callbacks functions ==============================

func _on_auto_attack_timer_timeout() -> void:
	var target =  _source.target_manager.get_target(_attack_strategy)
	if target == null:
		return
	
	_auto_attack(target)
