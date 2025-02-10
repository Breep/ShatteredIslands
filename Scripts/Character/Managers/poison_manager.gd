class_name PoisonManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _poison_stats: CharacterPoisonStats # Ref to the owner poison stats

var _optional_timers: Array[Timer]

# ============================== Local scenes ==============================

@onready var _poison_tick_timer:Timer = %PoisonTickTimer

# ============================== Public functions ==============================

func start(source: Character, poison_stats: CharacterPoisonStats) -> void:
	if source == null:
		printerr("PoisonManager: source undef")
		return
	if poison_stats == null:
		printerr("PoisonManager: poison_stats undef")
		return
	
	_source = source
	_poison_stats = poison_stats
	_poison_tick_timer.start()
	_create_optional_timers()
	_lanch_optional_spells()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage(damage: int) -> int:
	return (damage - damage * _poison_stats.poison_resist / 100.0) as int


func add_to_poison_effects(source: Character, poison_stacks: int, poison_duration: int) -> void:
	if poison_stacks == 0:
		return
	
	for effect in _poison_stats.poison_effects:
		if effect.source == source and effect.ticks_left == poison_duration:
			effect.stacks_number += poison_stacks
			return
	
	var new_effect := PoisonEffect.new()
	new_effect.stacks_number = poison_stacks
	new_effect.ticks_left = poison_duration
	new_effect.source = source
	_poison_stats.poison_effects.append(new_effect)

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
	if target == null:
		return
	
	var poison_stacks = _poison_stats.periodic_stacks_number
	target.take_poison_stacks(_source, poison_stacks, 10)


# Handle poison stacks and damage on _source
func _on_poison_tick_timer_timeout() -> void:
	var poison_damage: int = 0
	for effect in _poison_stats.poison_effects:
		if effect.ticks_left > 0:
			effect.ticks_left -= 1
			if effect.source.stats.poison.multiply_damage_activated:
				poison_damage += effect.stacks_number * effect.source.stats.poison.multiply_damage
			else:
				poison_damage += effect.stacks_number
		else:
			_poison_stats.poison_effects.erase(effect)
	
	if poison_damage > 0:
		_source.take_damage(null, get_reduced_damage(poison_damage), Utils.DamageType.POISON, false)
