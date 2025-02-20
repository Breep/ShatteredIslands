class_name DefenseManager
extends FamilyManager

# ============================== Signals ==============================

signal armor_based_on_lost_hp_gained(percent_of_lost_hp: float)

# ============================== Private variables ==============================

var _defense_stats: CharacterDefenseStats # Ref to the owner defense stats

var _armor_lost_since_last_shield_strike: int = 0

# ============================== Public functions ==============================

func _specific_init() -> void:
	_defense_stats = _source.stats.defense
	_create_optional_timers()


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage_dealed_from_protector(damage: float) -> float:
	if not _defense_stats.protector_activated:
		return damage
	
	var damage_reduction = damage * _defense_stats.protector_reduce_damage_done / 100.0
	return damage - damage_reduction


func get_reduced_damage_taken_from_protector(damage: int) -> int:
	if not _defense_stats.protector_activated:
		return damage
	
	var damage_reduction: int = ((damage as float * _defense_stats.protector_reduce_damage_received) / 100.0) as int
	return damage - damage_reduction


func get_reduced_damage_taken_from_armor(damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type == Utils.DamageType.POISON: # Armor doesn't work on poison
		return damage
	
	if damage_type == Utils.DamageType.PHYSICAL: # Physical damage can trigger backfire
		_handle_backfires(damage_source)
	
	var damage_reduction = min(damage, _defense_stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	_defense_stats.armor_stacks -= damage_reduction
	_armor_lost_since_last_shield_strike += damage_reduction
	return damage_reduced


func notify_heal_received(heal: int) -> void:
	if not _defense_stats.healing_armor_activated:
		return
	
	_defense_stats.armor_stacks += (heal * _defense_stats.healing_armor_percent as float / 100.0) as int

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Shield yourself
	if _defense_stats.periodic_armor_stacks_amount > 0:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.periodic_armor_stacks_period, _on_periodic_armor_stacks_timer_timeout))
	
	# Shield strike
	if _defense_stats.shield_strike_damage_percent > 0:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.shield_strike_period, _on_shield_strike_timer_timeout))
	
	# Armor
	if _defense_stats.lost_hp_armor_gain_percent > 0:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.lost_hp_armor_gain_period, _on_lost_hp_armor_gain_timer_timeout))


func _handle_backfires(damage_source: Character) -> void:
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_armor_gain_chance):
		_defense_stats.armor_stacks += _defense_stats.backfire_armor_gain_stacks
	
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_fire_shield_chance):
		_action_module.direct_attack_percent(damage_source, _defense_stats.backfire_fire_shield_damage, Utils.DamageType.MAGICAL, Utils.PercentModifier.CURRENT_HP)
	
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_poison_chance):
		_action_module.inflict_condition_stacks(damage_source, _defense_stats.backfire_poison_stacks, Utils.StackType.POISON, 10)
	
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_vulnerability_chance):
		_action_module.inflict_condition_stacks(damage_source, _defense_stats.backfire_vulnerability_stacks, Utils.StackType.VULNERABILITY)

# ============================== Callbacks functions ==============================

func _on_periodic_armor_stacks_timer_timeout() -> void:
	_defense_stats.armor_stacks += _defense_stats.periodic_armor_stacks_amount


func _on_shield_strike_timer_timeout() -> void:
	if _armor_lost_since_last_shield_strike > 0:
		var damage = _armor_lost_since_last_shield_strike * _defense_stats.shield_strike_damage_percent / 100.0
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
		if target == null:
			return
		_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)
		_armor_lost_since_last_shield_strike = 0


func _on_lost_hp_armor_gain_timer_timeout() -> void:
	armor_based_on_lost_hp_gained.emit(_defense_stats.lost_hp_armor_gain_percent)
