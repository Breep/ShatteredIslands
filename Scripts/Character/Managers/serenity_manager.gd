class_name SerenityManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _heal_stats: CharacterHealStats # Ref to the owner heal stats

var _optional_timers: Array[Timer]

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func start(source: Character, heal_stats: CharacterHealStats) -> void:
	print("HealManager: Starting")
	if source == null:
		printerr("HealManager: source undef")
		return
	if heal_stats == null:
		printerr("HealManager: storm_stats undef")
		return
	
	_source = source
	_heal_stats = heal_stats
	_create_optional_timers()
	_lanch_optional_spells()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Break armor
	if _heal_stats.periodic_heal_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _heal_stats.periodic_heal_period, _on_periodic_heal_timer_timeout))


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

func _on_periodic_heal_timer_timeout() -> void:
	print("HealManager: Periodic heal")
	
