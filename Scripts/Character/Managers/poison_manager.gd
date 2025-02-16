class_name PoisonManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _poison_stats: CharacterPoisonStats # Ref to the owner poison stats

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

# ============================== Spells scenes ==============================

@onready var _poison_cloud_area_scene: PackedScene = preload("res://Scenes/SpellsAndProjectiles/poison_cloud_area.tscn")

# ============================== Local scenes ==============================

@onready var _poison_tick_timer:Timer = %PoisonTickTimer

# ============================== Public functions ==============================

func init(source: Character, poison_stats: CharacterPoisonStats) -> void:
	if source == null:
		printerr("PoisonManager: source undef")
		return
	if poison_stats == null:
		printerr("PoisonManager: poison_stats undef")
		return
	
	_source = source
	_poison_stats = poison_stats
	_create_optional_timers()


func start() -> void:
	for timer in _optional_timers:
		timer.stop()
	_lanch_optional_spells()
	_poison_tick_timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	for spell in _optional_spells:
		spell.queue_free()
	for poison_effect in _poison_stats.poison_effects.duplicate():
		_poison_stats.poison_effects.erase(poison_effect)
	_poison_tick_timer.stop()


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
		Utils.create_perpetual_timer(self, _poison_stats.periodic_stacks_period, _on_periodic_stacks_timer_timeout)


func _lanch_optional_spells() -> void:
	# [Poison cloud]
	if _poison_stats.poison_cloud_activated:
		var poison_cloud_area: PoisonCloudArea = _poison_cloud_area_scene.instantiate()
		poison_cloud_area.init(_source, _poison_stats.poison_cloud_stacks_number, _poison_stats.poison_cloud_stacks_period, _poison_stats.poison_cloud_range)
		_source.add_child(poison_cloud_area)
		poison_cloud_area.position = Vector3.ZERO
		_optional_spells.append(poison_cloud_area)

# ============================== Callbacks functions ==============================

func _on_periodic_stacks_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
	if target == null:
		return
	
	var poison_stacks = _poison_stats.periodic_stacks_number
	target.take_condition_stacks(poison_stacks, Utils.StackType.POISON, _source, 10)


# Handle poison stacks and damage on _source
var __fire_poison_stacks_count: Dictionary # {Character: int}
func _on_poison_tick_timer_timeout() -> void:
	var poison_damage: int = 0
	for effect in _poison_stats.poison_effects:
		if effect.ticks_left > 0:
			effect.ticks_left -= 1
			if effect.source.stats.poison.multiply_damage_activated:
				poison_damage += effect.stacks_number * effect.source.stats.poison.multiply_damage # [Venomous snake]
			else:
				poison_damage += effect.stacks_number
		else:
			_handle_fire_poison(effect)
			_poison_stats.poison_effects.erase(effect)
	
	if poison_damage > 0:
		_source.take_damage(null, get_reduced_damage(poison_damage), Utils.DamageType.POISON, false)


# [Poison of fire]
func _handle_fire_poison(effect: PoisonEffect) -> void:
	if not effect.source.stats.poison.fire_poison_activated:
		return
	
	if __fire_poison_stacks_count.has(effect.source):
		__fire_poison_stacks_count[effect.source] += effect.stacks_number
	else:
		__fire_poison_stacks_count[effect.source] = effect.stacks_number
	
	if multiplayer.get_unique_id() == 1: print("POISON/FIRE: ", __fire_poison_stacks_count[effect.source])
	
	if __fire_poison_stacks_count[effect.source] >= effect.source.stats.poison.fire_poison_stacks_lost:
		if multiplayer.get_unique_id() == 1: print("POISON/FIRE: EXPLOSION")
		effect.source.attack_percent(_source, effect.source.stats.poison.fire_poison_damage, Utils.DamageType.MAGIC, Utils.PercentModifier.MAX_HP)
		__fire_poison_stacks_count[effect.source] -= effect.source.stats.poison.fire_poison_stacks_lost
