class_name LifeManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _life_stats: CharacterLifeStats # Ref to the owner life stats

var _optional_timers: Array[Timer]

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func start(source: Character, life_stats: CharacterLifeStats) -> void:
	if source == null:
		printerr("LifeManager: source undef")
		return
	if life_stats == null:
		printerr("LifeManager: fire_stats undef")
		return
	
	_source = source
	_life_stats = life_stats
	_create_optional_timers()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage_taken_from(_damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if not _life_stats.damage_taken_reduced_below_treshold_activated:
		return damage
	
	var life_ratio: float = (_source.stats.health as float / _source.stats.health_max as float) * 100.0
	if multiplayer.get_unique_id() == 1:
		print("life_ratio = ", life_ratio, " | Threshold = ", _life_stats.damage_taken_reduced_below_treshold_threshold)
	if life_ratio <= _life_stats.damage_taken_reduced_below_treshold_threshold:
		var damage_reduction = (damage as float) * _life_stats.damage_taken_reduced_below_treshold_percentage / 100.0
		if multiplayer.get_unique_id() == 1:
			print("Damage reduced by ", damage_reduction, " | damage = ", damage)
		return damage - damage_reduction
	
	return damage

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	if _life_stats.poison_by_lost_hp_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _life_stats.poison_by_lost_hp_period, _on_poison_by_lost_hp_timer_timeout))
	pass

# ============================== Callbacks functions ==============================

func _on_poison_by_lost_hp_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
	if target == null:
		return
	var lost_hp: int = _source.stats.health_max - _source.stats.health
	var stack_multiplier: int = _life_stats.poison_by_lost_hp_stacks
	var poison_stacks: int = (lost_hp / _life_stats.poison_by_lost_hp_hp_number) * stack_multiplier
	print("Inflict ", poison_stacks, " poison stacks ! - ", _source.stats.health_max - _source.stats.health)
	target.take_poison_stacks(_source, poison_stacks, 5)
