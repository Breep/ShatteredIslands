class_name AttackManager
extends FamilyManager

# ============================== Signals ==============================

signal focus_changed(focused: bool)

# ============================== Constants ==============================

const ATTACK_SPEED_BOOST_OVERTIME_PERIOD: float = 1

# ============================== Private variables ==============================

var _attack_stats: CharacterAutoAttackStats # Ref to the owner attack stats

var _aa_speed_overtime_time_started: float = 0

var _focus_timer: Timer
var _focused: bool

var _aa_counter: int
var _previous_target: Character

# ============================== Public functions ==============================

func _specific_init() -> void:
	_attack_stats = _source.stats.auto_attack
	_create_optional_timers()


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func notice_auto_attack_done(target: Character) -> void:
	_aa_counter += 1
	
	# [Focus]
	if _source.stats.storm.focus_target_activated:
		_check_storm_focus(target)
		_previous_target = target
	
	# [Necrosis scythe]
	if _attack_stats.increase_max_hp_activated and _aa_counter % _attack_stats.increase_max_hp_period == 0:
		_source.stats.health_max += _attack_stats.increase_max_hp_amount
		_source.stats.health += _attack_stats.increase_max_hp_amount
	
	# [Sword armor]
	if Utils.is_randomize_modifier_active(_attack_stats.armor_stacks_chance):
		_source.stats.defense.armor_stacks += _attack_stats.armor_stacks_amount
	
	# [Knife of terror]
	if Utils.is_randomize_modifier_active(_attack_stats.healing_attack_chance):
		var heal_target: Character = _source.target_manager.get_target(TargetManager.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		_source.heal(heal_target, _attack_stats.healing_attack_heal_amount)


func update_aa_projectile_stats(projectile_stats: ProjectileStats) -> void:
	pass

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Gatling]
	if _attack_stats.gatling_gun_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, ATTACK_SPEED_BOOST_OVERTIME_PERIOD, _on_aa_speed_overtime_timer_timeout))
		_aa_speed_overtime_time_started = Time.get_ticks_msec()


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

func _on_aa_speed_overtime_timer_timeout() -> void:
	var time_elapsed: float = Time.get_ticks_msec() - _aa_speed_overtime_time_started
	var attack_speed_boost = remap(time_elapsed, 0, _attack_stats.gatling_gun_duration, \
			_attack_stats.gatling_gun_min, _attack_stats.gatling_gun_max)
	attack_speed_boost = clampf(attack_speed_boost, _attack_stats.gatling_gun_min, _attack_stats.gatling_gun_max)
	# _update_auto_attack_speed()


func _on_focus_timer_timeout() -> void:
	_focused = true
	focus_changed.emit(true)
