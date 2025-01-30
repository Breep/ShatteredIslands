class_name AutoAttackManager
extends Node

# ============================== Signals ==============================

signal armor_gained(armor_stacks: int)
signal max_health_gained(health_amount: int)
signal heal_ally_triggered(heal_amount: int)

# ============================== Export variables ==============================

@export var projectile_spawn: Node2D

# ============================== Public variables ==============================

var aa_counter: int = 0 # Counter of auto attacks

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _aa_stats: CharacterAutoAttackStats # Ref to the owner auto attack stats
var _projectile_scene: PackedScene # Ref to the AutoAttackProjectile packed scene
var _forced_target: Character # TODO Unused now, maybe for a futur hero that can taunt ?
var _enemies: Array[Character] # Ref to all enemies of the owner in the battlefield
var _attack_strategy: Targetter.TargettingStrategy = Targetter.TargettingStrategy.CLOSEST # The algo used to find the target

# ============================== Local scene nodes ==============================

@onready var _auto_attack_timer: Timer = %AutoAttackTimer

# ============================== Public functions ==============================

func start(source: Character,
		projectile_scene: PackedScene,
		aa_stats: CharacterAutoAttackStats,
		enemies: Array[Character]) -> void:
	if aa_stats == null:
		printerr("AutoAttackManager: aa_stats undef")
		return
	if projectile_scene == null:
		printerr("AutoAttackManager: projectile_scene undef")
		return
	if enemies.is_empty():
		push_warning("AutoAttackManager: no enemies")
		return
	if source == null:
		printerr("AutoAttackManager: source undef")
		return
	if projectile_spawn == null:
		printerr("AutoAttackManager: projectile_spawn undef")
		return
	
	_source = source
	_projectile_scene = projectile_scene
	_aa_stats = aa_stats
	_enemies = enemies
	set_auto_attack_speed(_aa_stats.attack_speed)
	_auto_attack_timer.start()


func set_auto_attack_speed(attack_speed: float) -> void:
	if attack_speed <= 0:
		printerr("AutoAttackManager: Attack speed is lower than 0 !")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / attack_speed

# ============================== Private functions ==============================

func _auto_attack():
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
	if _is_randomize_modifier_active(_aa_stats.armor_stacks_chance):
		armor_gained.emit(_aa_stats.armor_stacks_amount)
	
	# Knife of terror
	if _is_randomize_modifier_active(_aa_stats.healing_attack_chance):
		heal_ally_triggered.emit(_aa_stats.healing_attack_heal_amount)
	
	_spawn_projectile()
	_aa_stats.fire_attack_triggered = false


func _spawn_projectile() -> void:
	var projectile: AutoAttackProjectile = _projectile_scene.instantiate()
	projectile.init(_source, Targetter.get_target(_attack_strategy), _aa_stats)
	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position + Vector2(randf_range(-10,10), randf_range(-10,10))


func _is_randomize_modifier_active(chance: float) -> bool: # TODO Move to lib
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance




# ============================== Callbacks functions ==============================

func _on_auto_attack_timer_timeout() -> void:
	_auto_attack()
