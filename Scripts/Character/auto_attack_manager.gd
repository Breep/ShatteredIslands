class_name AutoAttackManager
extends Node

enum AttackStrategy {
	CLOSEST,
	FARTHEST,
	RANDOM,
}

signal armor_gained(armor_stacks)
signal max_health_gained(health_amount)
signal heal_ally_triggered(heal_amount)

var aa_counter: int = 0

@export var projectile_spawn: Node2D

var source: Character
var aa_stats: CharacterAutoAttackStats
var projectile_scene: PackedScene
var forced_target: Character
var enemies: Array[Character]
var attack_strategy: AttackStrategy = AttackStrategy.CLOSEST

@onready var _auto_attack_timer: Timer = %AutoAttackTimer

var _target: Character

func start() -> void:
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
	
	print("AutoAttackManager: starting !")
	_auto_attack_timer.start()

func set_auto_attack_speed(attack_speed: float) -> void:
	if attack_speed <= 0:
		printerr("attack speed is lower than 0 !")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / attack_speed

func _auto_attack():
	aa_counter += 1
	if aa_stats.fire_attack_activated:
		if aa_counter % aa_stats.fire_attack_period == 0:
			aa_stats.fire_attack_triggered = true
	
	if aa_stats.increase_max_hp_activated:
		if aa_counter % aa_stats.increase_max_hp_period == 0:
			max_health_gained.emit(aa_stats.increase_max_hp_amount)
	
	if _is_randomize_modifier_active(aa_stats.armor_stacks_chance):
		armor_gained.emit()
	
	if _is_randomize_modifier_active(aa_stats.healing_attack_chance):
		heal_ally_triggered.emit(aa_stats.healing_attack_heal_amount)
	
	_create_aa_projectile_from_character(aa_stats)
	aa_stats.fire_attack_triggered = false


# TODO Rework ces 3 fonctions Dé gueu lasse
func _create_aa_projectile_from_character(character_stats: CharacterAutoAttackStats) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.target = _get_target()
	projectile.set_stats_from_character_aa_stats(character_stats)
	_spawn_projectile(projectile)


func _create_aa_projectile_from_projectile(projectile_stats: AutoAttackProjectileStats) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.aa_stats = projectile_stats
	_spawn_projectile(projectile)


func _spawn_projectile(projectile: Projectile) -> void:
	if source == null:
		printerr("Can't create a projectile with no source character")
		return
	
	projectile.target = _get_target()
	projectile.source = source
	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position + Vector2(randf_range(-10,10), randf_range(-10,10))
	projectile.global_rotation = projectile_spawn.global_rotation
 

func _is_randomize_modifier_active(chance: float) -> bool:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance


func _on_auto_attack_timer_timeout() -> void:
	_auto_attack()


func _get_target() -> Character:
	match attack_strategy:
		AttackStrategy.CLOSEST:
			return _get_closest_enemy()
		AttackStrategy.FARTHEST:
			printerr("Not implemented yet !")
			return null
		AttackStrategy.RANDOM:
			printerr("Not implemented yet !")
			return null
	
	printerr("Undef strategy for the AutoAttackManager")
	return null


func _get_closest_enemy() -> Character:
	if enemies.is_empty():
		return null
	
	var closest_enemy: Character = enemies[0]
	for enemy in enemies:
		if (enemy.position - source.position).length_squared() < (closest_enemy.position - source.position).length_squared():
			closest_enemy = enemy
	
	return closest_enemy
