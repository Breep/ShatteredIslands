class_name DefenseManager
extends FamilyManager

# ============================== Signals ==============================

signal armor_based_on_lost_hp_gained(percent_of_lost_hp: float)

# ============================== Private variables ==============================

var _defense_stats: CharacterDefenseStats # Ref to the owner defense stats
var _armor_lost_since_last_hedgehog_armor: int = 0
var _mystical_shoulders_damage_reduced_percent: float
var _rng: RandomNumberGenerator

# ============================== Public functions ==============================

func _specific_init() -> void:
	_defense_stats = _source.stats.defense
	_create_optional_timers()


func start() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_increased_damage_done_from_power_wrist(damage: int) -> int:
	if not _defense_stats.power_wrists_activated:
		return damage
	
	var power_stacks: int = _defense_stats.armor_stacks / _defense_stats.power_wrists_armor_stacks
	var damage_inc_percent: int = _defense_stats.power_wrists_damage_increase_percent * power_stacks
	var damage_inc: int = ((damage as float * damage_inc_percent) / 100.0) as int
	return damage + damage_inc


func get_reduced_damage_taken_from_mystical_shoulder(damage: int) -> int:
	if not _defense_stats.mystical_shoulders_activated:
		return damage
	
	var damage_reduction: int = ((damage as float * _defense_stats._mystical_shoulders_damage_reduced_percent) / 100.0) as int
	return damage - damage_reduction


func get_reduced_damage_taken_from_armor(damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type == Utils.DamageType.POISON: # Armor doesn't work on poison
		return damage
	
	var damage_reduction = min(damage, _defense_stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	_defense_stats.armor_stacks -= damage_reduction
	_armor_lost_since_last_hedgehog_armor += damage_reduction
	_rainbow_boots_effect(damage_reduction)
	return damage_reduced


# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	if _defense_stats.hedgehog_armor_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.hedgehog_armor_period, _on_hedgehog_armor_period_timeout, true))


func _gain_armor(armor_stacks: int) -> void:
	if _defense_stats.dual_shield_activated:
		var health_ratio: float = (_source.stats.health as float / _source.stats.health_max) * 100.0
		if health_ratio >= _defense_stats.dual_shield_health_threshold:
			armor_stacks *= 2
	
	_defense_stats.armor_stacks += armor_stacks


func _rainbow_boots_effect(armor_lost: int) -> void:
	if not _defense_stats.rainbow_boots_activated:
		return
	
	var number_of_procs: int = armor_lost / _defense_stats.rainbow_boots_armor_stacks
	for i in number_of_procs:
		var effects: Array[Utils.StackType] = [Utils.StackType.POISON, Utils.StackType.VULNERABILITY]
		var effect: Utils.StackType = effects[_rng.randi_range(0, effects.size() - 1)]
		var target: Entity = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
		_action_module.inflict_condition_stacks(target, 1, effect)

# ============================== Callbacks functions ==============================

func _on_hedgehog_armor_period_timeout() -> void:
	var target: Entity = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST)
	if target == null: return
	var damage: int = (_armor_lost_since_last_hedgehog_armor * _defense_stats.hedgehog_armor_lost_armor_percent as float / 100.0) as int
	_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)
