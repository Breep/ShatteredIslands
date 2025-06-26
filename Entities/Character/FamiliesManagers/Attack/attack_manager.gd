class_name AttackManager
extends FamilyManager

# ============================== Signals ==============================

signal focus_changed(focused: bool)

# ============================== Constants ==============================

const GATLING_TIME: float = 1

# ============================== Export ==============================

#@export_group("External Nodes")
#@export var _auto_attack_module: AutoAttackModule

# ============================== Private variables ==============================

var _attack_stats: FamilyAttackStats # Ref to the owner attack stats
var _aa_counter: int

var _on_gatling_gun_timer_start: float = 0

var _gatling_speed_boost: float = 0 # Boost of attack speed from [Gatling Gun]
var gatling_speed_boost: float:
	get: return _gatling_speed_boost
	set(value):
		if _gatling_speed_boost == value: return
		_gatling_speed_boost = value
		_owner.stats.attack_speed_boost = _attack_stats.twin_blade_speed + _gatling_speed_boost



# ============================== Public functions ==============================

func _ready() -> void:
	_attack_stats = _owner.families_stats.auto_attack


func start() -> void:
	_aa_counter = 0
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()


func apply_stats_modifiers() -> void:
	if _attack_stats.diamond_sword_activated:
		_owner.stats.attack_damage += _attack_stats.diamond_sword_attack
	
	if _attack_stats.twin_blade_activated:
		_owner.stats.attack_speed_boost += _attack_stats.twin_blade_speed


func attack(target: Character, projectile_spawn: SpawnPoint) -> void:
	_aa_counter += 1
	if _attack_stats.curative_knife_activated and Utils.is_randomize_modifier_active(_attack_stats.curative_knife_chance):
		_remove_random_debuff_stack(_attack_stats.curative_knife_stacks)
	var projectile_stats := ProjectileStats.new()
	projectile_stats.physical_damage_flat = _owner.stats.attack_damage
	if _attack_stats.titan_axe_activated and _aa_counter % _attack_stats.titan_axe_attack_number == 0:
		projectile_stats.physical_damage_percent = _attack_stats.titan_axe_damage_percent
		projectile_stats.physical_damage_percent_type = Utils.PercentModifier.MAX_HP
	projectile_stats.speed = 15
	_owner.projectile_attack(target, Projectile.ProjectileType.AUTO_ATTACK, projectile_spawn, projectile_stats)


func notify_damage_done(damage: int) -> void:
	if _attack_stats.healing_crossbow_activated:
		if Utils.is_randomize_modifier_active(_attack_stats.healing_crossbow_chance):
			var heal_amount: int = (damage as float * _attack_stats.healing_crossbow_percent / 100.0) as int
			_owner.heal(_owner, heal_amount)

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Gatling Gun]
	if _attack_stats.gatling_gun_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, GATLING_TIME, _on_gatling_gun_timer_timeout, true))
		_on_gatling_gun_timer_start = Time.get_ticks_msec()


func _remove_random_debuff_stack(stack_number: int) -> void:
	var random_stacks_types: Array[Utils.StackType]
	if _owner.stats.poison_stacks > 0: random_stacks_types.append(Utils.StackType.POISON)
	if _owner.stats.ignite_stacks > 0: random_stacks_types.append(Utils.StackType.IGNITE)
	var random_stack_type: Utils.StackType = random_stacks_types.pick_random()
	match random_stack_type:
		Utils.StackType.POISON: _owner.stats.poison_stacks -= stack_number
		Utils.StackType.IGNITE: _owner.stats.ignite_stacks -= stack_number

# ============================== Callbacks functions ==============================

func _on_gatling_gun_timer_timeout() -> void:
	var time_elapsed: float = (Time.get_ticks_msec() - _on_gatling_gun_timer_start) / 1000.0
	var attack_speed_boost = remap(time_elapsed, 0, _attack_stats.gatling_gun_duration, \
			_attack_stats.gatling_gun_min, _attack_stats.gatling_gun_max)
	gatling_speed_boost = clampf(attack_speed_boost, _attack_stats.gatling_gun_min, _attack_stats.gatling_gun_max)
