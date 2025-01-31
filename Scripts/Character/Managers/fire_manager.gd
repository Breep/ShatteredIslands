class_name FireManager
extends Node

# ============================== Signals ==============================


# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _fire_stats: CharacterFireStats # Ref to the owner auto attack stats

var _optional_timers: Array[Timer]

# ============================== Public functions ==============================

func start(source: Character, fire_stats: CharacterFireStats) -> void:
	print("FireManager: Starting")
	if source == null:
		printerr("FireManager: source undef")
		return
	if fire_stats == null:
		printerr("FireManager: fire_stats undef")
		return
	
	_source = source
	_fire_stats = fire_stats
	_create_optional_timers()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage_taken_from(damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type != Utils.DamageType.MAGIC:
		return damage
	
	var damage_reduced = damage - damage * _fire_stats.magic_resist_percent / 100.0
	return damage_reduced

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Fire dagger bolt
	if _fire_stats.firebolt_damage > 0:
		_optional_timers.append(Utils.create_optional_timer(self, _fire_stats.firebolt_period, _on_firebolt_timer_timeout))

# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	print("FireManager: FIREBOLT")
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST)
	target.take_damage_percent(_source, _fire_stats.firebolt_damage, Utils.DamageType.MAGIC)
