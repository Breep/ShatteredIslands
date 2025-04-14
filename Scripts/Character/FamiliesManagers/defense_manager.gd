class_name DefenseManager
extends FamilyManager

# ============================== Signals ==============================

signal reflecto_belt_activated(damage_inc_percent: int)

# ============================== Private variables ==============================

var _defense_stats: CharacterDefenseStats # Ref to the owner defense stats
var _mystical_shoulders_damage_reduced_percent: float
var _rng: RandomNumberGenerator

var _armor_lost_since_last_hedgehog_armor: int
var _armor_lost_since_last_rainbow_boots: int
var _armor_lost_since_last_reflecto_belt: int
var _total_magical_damage_blocked: int

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
	_reflecto_belt_effect(damage_reduction)
	return damage_reduced


# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	if _defense_stats.hedgehog_armor_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.hedgehog_armor_period, _on_hedgehog_armor_period_timeout, true))
	
	if _defense_stats.gladiator_helmet_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.gladiator_helmet_period, _on_gladiator_helmet_period_timeout, true))
	
	if _defense_stats.titan_gloves_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.titan_gloves_period, _on_titan_gloves_period_timeout, true))


func _gain_armor(armor_stacks: int) -> void:
	if _defense_stats.dual_shield_activated:
		var health_ratio: float = (_source.stats.health as float / _source.stats.health_max) * 100.0
		if health_ratio >= _defense_stats.dual_shield_health_threshold:
			armor_stacks *= 2
	
	_defense_stats.armor_stacks += armor_stacks


func _rainbow_boots_effect(armor_lost: int) -> void:
	if not _defense_stats.rainbow_boots_activated:
		return
	
	_armor_lost_since_last_rainbow_boots += armor_lost
	if _armor_lost_since_last_rainbow_boots < _defense_stats.rainbow_boots_armor_stacks:
		return
	
	var number_of_procs: int = armor_lost / _defense_stats.rainbow_boots_armor_stacks
	_armor_lost_since_last_rainbow_boots -= number_of_procs * _defense_stats.rainbow_boots_armor_stacks
	for i in number_of_procs:
		var effects: Array[Utils.StackType] = [Utils.StackType.POISON, Utils.StackType.VULNERABILITY]
		var effect: Utils.StackType = effects[_rng.randi_range(0, effects.size() - 1)]
		var target: Entity = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
		_action_module.inflict_condition_stacks(target, 1, effect)


func _reflecto_belt_effect(armor_lost: int) -> void:
	if not _defense_stats.reflecto_belt_activated:
		return
	
	_armor_lost_since_last_reflecto_belt += armor_lost
	if _armor_lost_since_last_reflecto_belt >= _defense_stats.reflecto_belt_armor_stacks:
		reflecto_belt_activated.emit(_defense_stats.reflecto_belt_attack_increase_percent)
		_armor_lost_since_last_reflecto_belt = 0


func _smith_hammer_effect() -> void:
	if not _defense_stats.smith_hammer_activated:
		return
	
	if Utils.is_randomize_modifier_active(_defense_stats.smith_hammer_chance_percent):
		_gain_armor(_defense_stats.smith_hammer_armor_stacks)


func _mystical_shoulders(magical_damage_blocked: int) -> void:
	if not _defense_stats.mystical_shoulders_activated:
		return
	
	_total_magical_damage_blocked += magical_damage_blocked
	var number_of_proc: int = _total_magical_damage_blocked / _defense_stats.mystical_shoulders_magic_damage
	_mystical_shoulders_damage_reduced_percent = number_of_proc * _defense_stats.mystical_shoulders_percent_inc
	_mystical_shoulders_damage_reduced_percent = clampf(_mystical_shoulders_damage_reduced_percent, 0, _defense_stats.mystical_shoulders_percent_max)

# ============================== Callbacks functions ==============================

func _on_hedgehog_armor_period_timeout() -> void:
	var target: Entity = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST)
	if target == null: return
	var damage: int = (_armor_lost_since_last_hedgehog_armor * _defense_stats.hedgehog_armor_lost_armor_percent as float / 100.0) as int
	_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)
	_armor_lost_since_last_hedgehog_armor = 0


func _on_gladiator_helmet_period_timeout() -> void:
	_gain_armor(_defense_stats.gladiator_helmet_armor_stacks)


func _on_titan_gloves_period_timeout() -> void:
	var ratio: float = _defense_stats.titan_gloves_max_health_percent as float / 100.0
	var armor_stacks: int = (_source.stats.health_max * ratio) as int
	_gain_armor(armor_stacks)
