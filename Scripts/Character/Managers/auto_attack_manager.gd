class_name AutoAttackManager
extends Node

# ============================== Signals ==============================

signal focus_changed(focused: bool)

# ============================== Constants ==============================

const ATTACK_SPEED_BOOST_OVERTIME_PERIOD: float = 1

# ============================== Export variables ==============================

@export var projectile_spawn: Node3D

# ============================== Public variables ==============================

var _aa_counter: int = 0 # Counter of auto attacks

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _aa_stats: CharacterAutoAttackStats # Ref to the owner auto attack stats
var _projectile_scene: PackedScene # Ref to the AutoAttackProjectile packed scene
#var _forced_target: Character # TODO Unused now, maybe for a futur hero that can taunt ?
var _attack_strategy: TargetManager.TargettingStrategy = TargetManager.TargettingStrategy.CLOSEST_ENEMY # The algo used to find the target
var _default_attack_speed: float # Default attack speed of the hero
var _previous_target: Character # Target of the previous auto attack

var _optional_timers: Array[Timer]

var _focus_timer: Timer
var _focused: bool

# ============================== Local scene nodes ==============================

@onready var _auto_attack_timer: Timer = %AutoAttackTimer

# ============================== Public functions ==============================

func init(source: Character, aa_stats: CharacterAutoAttackStats, projectile_scene: PackedScene, hero: Hero) -> void:
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
	_default_attack_speed = hero.stats.attack_speed
	_update_auto_attack_speed()


func start() -> void:
	_create_optional_timers()
	_auto_attack_timer.start()


func stop() -> void:
	print("AutoAttackManager: Stopping")
	_auto_attack_timer.stop()
	for timer in _optional_timers:
		timer.stop()


func set_auto_attack_speed(attack_speed: float) -> void:
	if attack_speed <= 0:
		printerr("AutoAttackManager: Attack speed is lower than 0 !")
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / attack_speed

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Gatling]
	if _aa_stats.attack_speed_overtime_max > 0:
		_optional_timers.append(Utils.create_optional_timer(self, ATTACK_SPEED_BOOST_OVERTIME_PERIOD, _on_aa_speed_overtime_timer_timeout))
	
	# [Focus]
	if _source.stats.storm.focus_target_activated:
		_focus_timer = Timer.new()
		add_child(_focus_timer)
		_focus_timer.connect("timeout", _on_focus_timer_timeout)
		_focus_timer.wait_time = _source.stats.storm.focus_target_time_before
		_focus_timer.one_shot = 1


func _auto_attack(target: Character) -> void:
	_aa_counter += 1
	
	# [Focus]
	if _source.stats.storm.focus_target_activated:
		_check_storm_focus(target)
		_previous_target = target
	
	# [Fire sword]
	if _aa_stats.fire_attack_activated:
		if _aa_counter % _aa_stats.fire_attack_period == 0:
			_aa_stats.fire_attack_triggered = true
	
	# [Necrosis scythe]
	if _aa_stats.increase_max_hp_activated and _aa_counter % _aa_stats.increase_max_hp_period == 0:
		_source.stats.health_max += _aa_stats.increase_max_hp_amount
		_source.stats.health += _aa_stats.increase_max_hp_amount
	
	# [Sword armor]
	if Utils.is_randomize_modifier_active(_aa_stats.armor_stacks_chance):
		_source.stats.defense.armor_stacks += _aa_stats.armor_stacks_amount
	
	# [Knife of terror]
	if Utils.is_randomize_modifier_active(_aa_stats.healing_attack_chance):
		var heal_target: Character = _source.target_manager.get_target(TargetManager.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		_source.heal(heal_target, _aa_stats.healing_attack_heal_amount)
	 
	_spawn_projectile(target)
	_aa_stats.fire_attack_triggered = false


func _spawn_projectile(target: Character) -> void:
	var projectile: AutoAttackProjectile = _projectile_scene.instantiate()
	projectile.init(_source, target)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position + Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))


func _update_auto_attack_speed() -> void:
	_source.stats.attack_speed = _default_attack_speed
	var attack_speed_boost: float = _aa_stats.attack_speed_boost + _aa_stats.attack_speed_overtime_current
	var multiply_boost: float = remap(attack_speed_boost, 0, 100, 1, 2) # Convert % in proportional multiple (100% = x2 | 150% = x2.5)
	_source.stats.attack_speed *= multiply_boost
	set_auto_attack_speed(_source.stats.attack_speed)


func _check_storm_focus(target) -> void:
	if target == _previous_target and _focus_timer.is_stopped() and not _focused:
		_focus_timer.start()
	elif target != _previous_target:
		if not _focus_timer.is_stopped():
			_focus_timer.stop()
		if _focused:
			focus_changed.emit(false)
			_focused = false


# ============================== Callbacks functions ==============================

func _on_auto_attack_timer_timeout() -> void:
	var target =  _source.target_manager.get_target(_attack_strategy)
	if target == null:
		return
	
	_auto_attack(target)


var __aa_speed_overtime_ticks: int = 0 # static variable for _on_aa_speed_overtime_timer()
func _on_aa_speed_overtime_timer_timeout() -> void:
	var attack_speed_overtime_current = remap(__aa_speed_overtime_ticks, \
			0, _aa_stats.attack_speed_overtime_duration / ATTACK_SPEED_BOOST_OVERTIME_PERIOD, \
			_aa_stats.attack_speed_overtime_min, _aa_stats.attack_speed_overtime_max)
	_aa_stats.attack_speed_overtime_current = clampf(attack_speed_overtime_current, \
			_aa_stats.attack_speed_overtime_min, _aa_stats.attack_speed_overtime_max)
	_update_auto_attack_speed()
	__aa_speed_overtime_ticks += 1


func _on_focus_timer_timeout() -> void:
	_focused = true
	focus_changed.emit(true)
