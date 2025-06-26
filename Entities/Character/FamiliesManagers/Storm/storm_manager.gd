class_name StormManager
extends FamilyManager

# ============================== Constants ==============================

const FOCUS_INCREASE_CRIT_PERIOD: float = 0.5

# ============================== Private variables ==============================

var _storm_stats: FamilyStormStats

# ============================== Public functions ==============================

func _ready() -> void:
	_storm_stats = _owner.families_stats.storm


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_increased_critical_damage(damage: int, is_critical: bool) -> int:
	if not is_critical:
		return damage
	return damage


func get_critical_chance() -> float:
	return 10 # TODO A FAIRE


func get_critical_multiplier(damage_type: Utils.DamageType) -> float:
	if damage_type != Utils.DamageType.PHYSICAL:
		return 1 
	
	var critical_multiplier = _owner.stats.physical_critical_multiplier
	return critical_multiplier


func notice_critical_damage(_char_who_received_the_crit: Character, _damage: int) -> void:
	pass

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	pass

# ============================== Callbacks functions ==============================

func _on_vulnerability_timer_timeout() -> void:
	pass


func _on_crit_move_speed_timer_timeout() -> void:
	_storm_stats.speed_boosted = false
