class_name SerenityManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _heal_stats: CharacterHealStats # Ref to the owner heal stats

var _optional_timers: Array[Timer]

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func start(source: Character, heal_stats: CharacterHealStats) -> void:
	if source == null:
		printerr("HealManager: source undef")
		return
	if heal_stats == null:
		printerr("HealManager: storm_stats undef")
		return
	
	_source = source
	_heal_stats = heal_stats
	_create_optional_timers()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func notify_heal() -> void:
	# Magic heal
	if _heal_stats.heal_projectile_activated and Utils.is_randomize_modifier_active(_heal_stats.heal_projectile_chance):
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
		if target == null:
			return
		_source.attack(target, _heal_stats.heal_projectile_damage, Utils.DamageType.MAGIC)
	
	# Hazardous healing
	if _heal_stats.poison_stacks_activated and Utils.is_randomize_modifier_active(_heal_stats.poison_stacks_chance):
		var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.RANDOM_ENEMY)
		if target == null:
			return
		target.take_poison_stacks(_source, _heal_stats.poison_stacks_number, 5) # TODO relier à la duration du poison

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Flash heal
	if _heal_stats.periodic_heal_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _heal_stats.periodic_heal_period, _on_periodic_heal_timer_timeout))
	
	# Survivor
	if _heal_stats.lost_hp_regen_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _heal_stats.lost_hp_regen_period, _on_lost_hp_regen_timer_timeout))

	# Pacific wave
	if _heal_stats.epic_heal_area_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _heal_stats.epic_heal_area_period, _on_epic_heal_area_timer_timeout))

# ============================== Callbacks functions ==============================

func _on_periodic_heal_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	_source.heal(target, _heal_stats.periodic_heal_amount)


func _on_lost_hp_regen_timer_timeout() -> void:
	_source.heal_percent(_source, _heal_stats.lost_hp_regen_percentage, Utils.PercentModifier.LOST_HP)


func _on_epic_heal_area_timer_timeout() -> void:
	var targets = _source.target_manager.get_targets(TargetManager.MultipleTargettingStrategy.ALLIES)
	if targets.is_empty():
		return
	for target in targets:
		_source.heal_percent(target, _heal_stats.epic_heal_area_percentage, Utils.PercentModifier.MAX_HP)










	
