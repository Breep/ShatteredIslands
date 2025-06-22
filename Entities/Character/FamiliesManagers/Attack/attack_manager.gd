class_name AttackManager
extends FamilyManager

# ============================== Signals ==============================

signal focus_changed(focused: bool)

# ============================== Constants ==============================

const ATTACK_SPEED_BOOST_OVERTIME_PERIOD: float = 1

# ============================== Private variables ==============================

var _attack_stats: FamilyAttackStats # Ref to the owner attack stats

var _aa_speed_overtime_time_started: float = 0

var _focus_timer: Timer
var _focused: bool

var _aa_counter: int
var _previous_target: Character

# ============================== Public functions ==============================

func _ready() -> void:
	_attack_stats = _owner.families_stats.auto_attack


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func notice_auto_attack_done(_target: Character) -> void:
	_aa_counter += 1


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
