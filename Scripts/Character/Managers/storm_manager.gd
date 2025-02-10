class_name StormManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

@export var _percent_decrease: float # Percentage of vulnerability stacks removed per tick
@export var _minimum_stacks_decrease_flat: float # Minimum stacks removed each tick

var _source: Character # Ref to character owner
var _storm_stats: CharacterStormStats # Ref to the owner storm stats

var _optional_timers: Array[Timer]

# ============================== Local nodes ==============================

@onready var _vulnerability_timer: Timer = %VulnerabilityTimer

# ============================== Public functions ==============================

func init(source: Character, storm_stats: CharacterStormStats) -> void:
	if source == null:
		printerr("StormManager: source undef")
		return
	if storm_stats == null:
		printerr("StormManager: storm_stats undef")
		return
	
	_source = source
	_storm_stats = storm_stats


func start() -> void:
	_vulnerability_timer.start()
	_create_optional_timers()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	_vulnerability_timer.stop()


func get_increased_critical_damage(damage: int, is_critical: bool) -> int:
	if not is_critical:
		return damage
	var vulnerability_multiplier = remap(_storm_stats.vulnerability_stacks, 0, 100, 1, 2)
	return damage * vulnerability_multiplier


func get_critical_multiplier(damage_type: Utils.DamageType) -> float:
	if damage_type != Utils.DamageType.PHYSICAL:
		return 1 
	
	var critical_multiplier = _source.stats.physical_critical_multiplier
	if _storm_stats.lost_hp_crit_multiplier_activated:
		var lost_hp = _source.stats.health_max - _source.stats.health
		critical_multiplier += (lost_hp / _storm_stats.lost_hp_crit_multiplier_hp_number) * _storm_stats.lost_hp_crit_multiplier_amount / 100.0
	return critical_multiplier


func notice_critical_damage(char_who_received_the_crit: Character, damage: int) -> void:
	# Thunder priest
	if _storm_stats.crit_heal_activated:
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		_source.heal(target, damage * _storm_stats.crit_heal_amount as float / 100.0)
	
	# Poisonous lightning
	if _storm_stats.crit_poison_activated:
		var poison_stacks: int = (damage * _storm_stats.crit_poison_amount as float / 100.0) as int
		char_who_received_the_crit.take_poison_stacks(_source, poison_stacks, 5)
	
	# Thunder break
	if _storm_stats.crit_vulnerability_activated:
		var vuln_stacks: int = (damage * _storm_stats.crit_vulnerability_amount as float / 100.0) as int
		if multiplayer.get_unique_id() == 1: print(vuln_stacks)
		char_who_received_the_crit.take_condition_stacks(_source, vuln_stacks, Utils.StackType.VULNERABILITY)

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Break armor
	if _storm_stats.periodic_vulnerability_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _storm_stats.periodic_vulnerability_period, _on_periodic_vulnerability_timer_timeout))

# ============================== Callbacks functions ==============================

func _on_periodic_vulnerability_timer_timeout() -> void:
	#print("StormManager: Periodic vulnerability")
	var target: Character = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	
	var vulnerability_stacks: int = _storm_stats.periodic_vulnerability_amount
	target.take_condition_stacks(_source, vulnerability_stacks, Utils.StackType.VULNERABILITY)


func _on_vulnerability_timer_timeout() -> void:
	#print("StormManager: Vulnerability removal")
	var vulnerability_stacks_removed: int = (0.1 * _storm_stats.vulnerability_stacks) as int
	if vulnerability_stacks_removed < _minimum_stacks_decrease_flat:
		vulnerability_stacks_removed = _minimum_stacks_decrease_flat
	
	_storm_stats.vulnerability_stacks -= vulnerability_stacks_removed
	
	if _storm_stats.vulnerability_stacks < 0:
		_storm_stats.vulnerability_stacks = 0
