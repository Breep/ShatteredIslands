class_name DefenseManager
extends Node

# ============================== Signals ==============================

signal armor_based_on_lost_hp_gained(percent_of_lost_hp: float)

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _defense_stats: CharacterDefenseStats # Ref to the owner defense stats

var _armor_lost_since_last_shield_strike: int = 0

var _optional_timers: Array[Timer]

# ============================== Public functions ==============================

func start(source: Character, defense_stats: CharacterDefenseStats) -> void:
	print("DefenseManager: Starting")
	if source == null:
		printerr("DefenseManager: source undef")
		return
	if defense_stats == null:
		printerr("DefenseManager: defense_stats undef")
		return
	
	_source = source
	_defense_stats = defense_stats
	_create_optional_timers()


func stop() -> void:
	print("DefenseManager: Stopping")
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage_taken_from(damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type == Utils.DamageType.PHYSICAL:
		_handle_backfires(damage_source)
	
	var damage_reduction = min(damage, _defense_stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	_defense_stats.armor_stacks -= damage_reduction
	_armor_lost_since_last_shield_strike += damage_reduction
	return damage_reduced

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Shield yourself
	if _defense_stats.periodic_armor_stacks_amount > 0:
		_optional_timers.append(Utils.create_optional_timer(self, _defense_stats.periodic_armor_stacks_period, _on_periodic_armor_stacks_timer_timeout))
	
	# Shield strike
	if _defense_stats.shield_strike_damage_percent > 0:
		_optional_timers.append(Utils.create_optional_timer(self, _defense_stats.shield_strike_period, _on_shield_strike_timer_timeout))
	
	# Armor
	if _defense_stats.lost_hp_armor_gain_percent > 0:
		_optional_timers.append(Utils.create_optional_timer(self, _defense_stats.lost_hp_armor_gain_period, _on_lost_hp_armor_gain_timer_timeout))


func _handle_backfires(damage_source: Character) -> void:
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_armor_gain_chance):
		_defense_stats.armor_stacks += _defense_stats.backfire_armor_gain_stacks
	
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_fire_shield_chance):
		damage_source.take_damage_percent(_source, _defense_stats.backfire_fire_shield_damage, Utils.DamageType.MAGIC)
	
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_poison_chance):
		damage_source.take_poison_stacks(_source, _defense_stats.backfire_poison_stacks, 10) # TODO Surement envoyer ce truc au poison manager car il faut connaitre la durée du poison
	
	if Utils.is_randomize_modifier_active(_defense_stats.backfire_vulnerability_chance):
		damage_source.take_condition_stacks(_source, _defense_stats.backfire_vulnerability_stacks, Utils.StackType.VULNERABILITY)

# ============================== Callbacks functions ==============================

func _on_periodic_armor_stacks_timer_timeout() -> void:
	_defense_stats.armor_stacks += _defense_stats.periodic_armor_stacks_amount


func _on_shield_strike_timer_timeout() -> void:
	if _armor_lost_since_last_shield_strike > 0:
		var damage = _armor_lost_since_last_shield_strike * _defense_stats.shield_strike_damage_percent / 100.0
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
		target.take_damage_flat(_source, damage, Utils.DamageType.MAGIC)
		_armor_lost_since_last_shield_strike = 0


func _on_lost_hp_armor_gain_timer_timeout() -> void:
	armor_based_on_lost_hp_gained.emit(_defense_stats.lost_hp_armor_gain_percent)
