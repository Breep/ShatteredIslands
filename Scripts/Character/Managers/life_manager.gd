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

func get_increased_damage_taken_from_lost_hp(_damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type != Utils.DamageType.PHYSICAL:
		return damage
	
	if not _damage_source.stats.hp.damage_increased_by_hp_lost_activated:
		return damage
	
	var lost_hp: int = _damage_source.stats.health_max - _damage_source.stats.health
	var damage_inc_percent: int = _damage_source.stats.hp.damage_increased_by_hp_lost_percentage
	var lost_hp_stacks: int = lost_hp / _damage_source.stats.hp.damage_increased_by_hp_lost_hp_number
	var damage_multiplier: float = remap(damage_inc_percent * lost_hp_stacks, 0, 100, 1, 2)

	return damage * damage_multiplier

func get_reduced_damage(damage: int) -> int:
	if not _life_stats.damage_taken_reduced_below_treshold_activated:
		return damage
	
	var life_ratio: float = (_source.stats.health as float / _source.stats.health_max as float) * 100.0
	if life_ratio <= _life_stats.damage_taken_reduced_below_treshold_threshold:
		var damage_reduction = (damage as float) * _life_stats.damage_taken_reduced_below_treshold_percentage / 100.0
		return damage - damage_reduction
	
	return damage

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Poisonous hearth
	if _life_stats.poison_by_lost_hp_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _life_stats.poison_by_lost_hp_period, _on_poison_by_lost_hp_timer_timeout))
	
	# Hearth of fire
	if _life_stats.fire_damage_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _life_stats.fire_damage_period, _on_fire_damage_timer_timeout))

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


func _on_fire_damage_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	var damage = _source.stats.health_max * _life_stats.fire_damage_percent / 100.0
	target.take_damage_flat(_source, damage, Utils.DamageType.MAGIC)
