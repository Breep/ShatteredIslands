class_name StormManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _storm_stats: CharacterStormStats # Ref to the owner storm stats

var _optional_timers: Array[Timer]

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func start(source: Character, storm_stats: CharacterStormStats) -> void:
	print("StormManager: Starting")
	if source == null:
		printerr("StormManager: source undef")
		return
	if storm_stats == null:
		printerr("StormManager: storm_stats undef")
		return
	
	_source = source
	_storm_stats = storm_stats
	_create_optional_timers()
	_lanch_optional_spells()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Break armor
	if _storm_stats.periodic_vulnerability_activated:
		Utils.create_optional_timer(self, _storm_stats.periodic_vulnerability_period, _on_periodic_vulnerability_timer_timeout)


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

func _on_periodic_vulnerability_timer_timeout() -> void:
	print("StormManager: Periodic vulnerability")
	var target: Character = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST)
	var vulnerability_stacks: int = _storm_stats.periodic_vulnerability_amount
	target.take_condition_stacks(_source, vulnerability_stacks, Utils.StackType.VULNERABILITY)
