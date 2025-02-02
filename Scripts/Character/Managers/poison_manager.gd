class_name PoisonManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _poison_stats: CharacterPoisonStats # Ref to the owner poison stats

var _optional_timers: Array[Timer]

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func start(source: Character, poison_stats: CharacterPoisonStats) -> void:
	print("PoisonManager: Starting")
	if source == null:
		printerr("PoisonManager: source undef")
		return
	if poison_stats == null:
		printerr("PoisonManager: poison_stats undef")
		return
	
	_source = source
	_poison_stats = poison_stats
	_create_optional_timers()
	_lanch_optional_spells()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage_taken_from(damage: int) -> int:
	return damage - damage * _poison_stats.poison_resist / 100.0

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Death flask
	if _poison_stats.periodic_stacks_activated:
		Utils.create_optional_timer(self, _poison_stats.periodic_stacks_period, _on_periodic_stacks_timer_timeout)


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

func _on_periodic_stacks_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
	var poison_stacks = _poison_stats.periodic_stacks_number
	target.take_poison_stacks(_source, poison_stacks, 10)
