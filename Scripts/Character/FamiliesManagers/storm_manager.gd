class_name StormManager
extends FamilyManager

# ============================== Constants ==============================

const FOCUS_INCREASE_CRIT_PERIOD: float = 0.5

# ============================== Private variables ==============================

@export var _percent_decrease: float # Percentage of vulnerability stacks removed per tick
@export var _minimum_stacks_decrease_flat: float # Minimum stacks removed each tick

var _storm_stats: CharacterStormStats # Ref to the owner storm stats

var _default_physical_critical_chance: float

var _focus_timer: Timer
var _crit_move_speed_timer: Timer

var _focus_timer_time_elapsed: float # Time elapsed since lanch of the timer

# ============================== Local nodes ==============================

@onready var _vulnerability_timer: Timer = %VulnerabilityTimer

# ============================== Public functions ==============================

func _specific_init() -> void:
	_storm_stats = _source.stats.storm
	_default_physical_critical_chance = _source.hero.stats.physical_critical_chance
	_create_optional_timers()


func start() -> void:
	for timer in _optional_timers:
		timer.start()
	_vulnerability_timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	_vulnerability_timer.stop()


func get_increased_critical_damage(damage: int, is_critical: bool) -> int:
	if not is_critical:
		return damage
	var vulnerability_multiplier = remap(_storm_stats.vulnerability_stacks, 0, 100, 1, 2)
	return damage * vulnerability_multiplier


func get_critical_chance() -> float:
	var crit_chance: float = _default_physical_critical_chance
	crit_chance += _storm_stats.focus_target_crit_current
	return crit_chance


func get_critical_multiplier(damage_type: Utils.DamageType) -> float:
	if damage_type != Utils.DamageType.PHYSICAL:
		return 1 
	
	var critical_multiplier = _source.stats.physical_critical_multiplier
	if _storm_stats.lost_hp_crit_multiplier_activated:
		var lost_hp = _source.stats.health_max - _source.stats.health
		critical_multiplier += (lost_hp / _storm_stats.lost_hp_crit_multiplier_hp_number) * _storm_stats.lost_hp_crit_multiplier_amount / 100.0
	return critical_multiplier


func notice_critical_damage(char_who_received_the_crit: Character, damage: int) -> void:
	# [Thunder priest]
	if _storm_stats.crit_heal_activated:
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		_action_module.heal(target, damage * _storm_stats.crit_heal_amount as float / 100.0)
	
	# [Poisonous lightning]
	if _storm_stats.crit_poison_activated:
		var poison_stacks: int = (damage * _storm_stats.crit_poison_amount as float / 100.0) as int
		_action_module.inflict_condition_stacks(char_who_received_the_crit, poison_stacks, Utils.StackType.POISON)
	
	# [Thunder break]
	if _storm_stats.crit_vulnerability_activated:
		var vuln_stacks: int = (damage * _storm_stats.crit_vulnerability_amount as float / 100.0) as int
		_action_module.inflict_condition_stacks(char_who_received_the_crit, vuln_stacks, Utils.StackType.VULNERABILITY)
	
	# [Lightning speed]
	if _storm_stats.crit_move_speed_activated:
		_storm_stats.speed_boosted = true
		if not _crit_move_speed_timer.is_stopped():
			_crit_move_speed_timer.stop()
		_crit_move_speed_timer.start()
	
	# [Overcharge]
	if _storm_stats.overcharge_activated:
		var target = _source.target_manager.get_closest_enemy_from(char_who_received_the_crit)
		if target != null:
			var overcharge_damage: int = (damage * _storm_stats.overcharge_percent / 100.0) as int
			if multiplayer.get_unique_id() == 1: print(char_who_received_the_crit.player.name, " ", target.player.name)
			_source.attack(target, overcharge_damage, Utils.DamageType.MAGICAL)


func focus_changed(focused: bool) -> void:
	if focused:
		_focus_timer_time_elapsed = 0
		__previous_time = Time.get_ticks_msec()
		_focus_timer.start()
	else:
		_focus_timer.stop()
		_storm_stats.focus_target_crit_current = 0

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Break armor
	if _storm_stats.periodic_vulnerability_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _storm_stats.periodic_vulnerability_period, _on_periodic_vulnerability_timer_timeout))
	
	if _storm_stats.focus_target_activated:
		_focus_timer = Timer.new()
		add_child(_focus_timer)
		_focus_timer.one_shot = true
		_focus_timer.wait_time = FOCUS_INCREASE_CRIT_PERIOD
		_focus_timer.connect("timeout", _on_focus_timer_timeout)
		_optional_timers.append(_focus_timer)
	
	if _storm_stats.crit_move_speed_activated:
		_crit_move_speed_timer = Timer.new()
		add_child(_crit_move_speed_timer)
		_crit_move_speed_timer.one_shot = true
		_crit_move_speed_timer.wait_time = _storm_stats.crit_move_speed_duration
		_crit_move_speed_timer.connect("timeout", _on_crit_move_speed_timer_timeout)
		_optional_timers.append(_crit_move_speed_timer)

# ============================== Callbacks functions ==============================

func _on_periodic_vulnerability_timer_timeout() -> void:
	var target: Character = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	
	var vulnerability_stacks: int = _storm_stats.periodic_vulnerability_amount
	_action_module.inflict_condition_stacks(target, vulnerability_stacks, Utils.StackType.VULNERABILITY)


func _on_vulnerability_timer_timeout() -> void:
	#print("StormManager: Vulnerability removal")
	var vulnerability_stacks_removed: int = ((_percent_decrease / 100.0) * _storm_stats.vulnerability_stacks as float) as int
	if vulnerability_stacks_removed < _minimum_stacks_decrease_flat:
		vulnerability_stacks_removed = _minimum_stacks_decrease_flat
	
	_storm_stats.vulnerability_stacks -= vulnerability_stacks_removed
	
	if _storm_stats.vulnerability_stacks < 0:
		_storm_stats.vulnerability_stacks = 0


var __previous_time: float
func _on_focus_timer_timeout() -> void:
	var time = Time.get_ticks_msec()
	_focus_timer_time_elapsed += time - __previous_time
	var focus_timer_ticks_max: int = (_storm_stats.focus_target_duration / FOCUS_INCREASE_CRIT_PERIOD) as int
	var physical_crit_inc: float = remap(_focus_timer_time_elapsed / 1000,                                  \
									0, _storm_stats.focus_target_duration,                                  \
									_storm_stats.focus_target_crit_min, _storm_stats.focus_target_crit_max)
	physical_crit_inc = clampf(physical_crit_inc, _storm_stats.focus_target_crit_min, _storm_stats.focus_target_crit_max)
	_storm_stats.focus_target_crit_current = physical_crit_inc
	__previous_time = time


func _on_crit_move_speed_timer_timeout() -> void:
	_storm_stats.speed_boosted = false
