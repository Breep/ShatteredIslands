class_name LifeManager
extends FamilyManager

# ============================== Signals ==============================

signal revived(life_after_revive: int)

# ============================== Private variables ==============================

var _life_stats: FamilyLifeStats # Ref to the owner life stats

var _revive_timer: Timer

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_life_stats = _owner.families_stats.life


func start() -> void:
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()
	_add_stat_modifiers()
	_add_action_modifiers()


func stop() -> void:
	_remove_action_modifiers()
	_clear_stat_modifiers()
	for timer in _optional_timers:
		timer.stop()
	_clear_optional_timers()


func get_increased_damage_taken_from_lost_hp(damage: float, _damage_type: Utils.DamageType) -> float:
	return damage

# [Revive]
func source_is_dead() -> void:
	if not _life_stats.revive_after_death_activated or _life_stats.revive_after_death_triggered:
		return
	
	_life_stats.revive_after_death_triggered = true
	_revive_timer.start()

# ============================== Private functions ==============================
#region optional timer

func _create_optional_timers() -> void:
	
	## Hearth of fire
	#if _life_stats.fire_damage_activated:
		#_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.fire_damage_period, _on_fire_damage_timer_timeout))
	#
	#if _life_stats.revive_after_death_activated:
		#_revive_timer = Timer.new()
		#_revive_timer.wait_time = _life_stats.revive_after_death_time
		#_revive_timer.one_shot = true
		#_revive_timer.timeout.connect(_on_revive_timer_timeout)
		#add_child(_revive_timer)
	
	# [TAINTED BLOOD]
	if _life_stats.tainted_blood_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.tainted_blood_period, _on_tainted_blood_timer_timeout, true))
		
	# [VITAL PULSE]
	if _life_stats.vital_pulse_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.vital_pulse_period, _vital_pulse_timer_timeout, true))

func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()

#endregion

#region aa modifier
#endregion

#region stats modifier

func _add_stat_modifiers() -> void:
	
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _life_stats.evasive_growth_increase_dodge
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Evasive Growth"
		_owner.stats_manager.register_modifier(mod)
		
	# [PROTEINS]
	if _life_stats.proteins_activated:
		var mod := StatModifier.new()
		mod.id = "Proteins"
		mod.stat_type = EntityStats.StatType.HEALTH_MAX
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _life_stats.proteins_max_hp_increase
		mod.tags = [StatModifier.TagType.CARD]

		_owner.stats_manager.register_modifier(mod)
		_owner.stats.health += _life_stats.proteins_max_hp_increase
		
func _clear_stat_modifiers() -> void:
	
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Evasive Growth"
		_owner.stats_manager.unregister_modifier(mod)
		
	# [PROTEINS]
	if _life_stats.proteins_activated:
		var mod := StatModifier.new()
		mod.id = "Proteins"
		mod.stat_type = EntityStats.StatType.HEALTH_MAX
		_owner.stats_manager.unregister_modifier(mod)
		
#endregion

#region action modifier


func _add_action_modifiers() -> void:
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Growth"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_evasive_growth
		_owner.action_modifiers_manager.register_modifier(action_modifier)

#endregion

func _remove_action_modifiers() -> void:
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Growth"
		action_modifier.after_action_logic_callback = _on_dodge_evasive_growth
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
		
#region other card

#endregion
# ============================== Callbacks functions ==============================

func _on_poison_by_lost_hp_timer_timeout() -> void:
	pass


func _on_fire_damage_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null: return
	var damage = _owner.stats.health_max * _life_stats.fire_damage_percent / 100.0
	_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)


func _on_revive_timer_timeout() -> void:
	print("REVIVE")
	print("Spawn revive bomb here")
	var life_after_revive: int = ((_life_stats.revive_after_death_percentage_life * _owner.stats.health_max) / 100.0) as int
	revived.emit(life_after_revive)

func _on_dodge_evasive_growth(cb_vars: Dictionary) -> void:
	# [EVASIVE GROWTH]
	if _owner == null or not is_instance_valid(_owner):
		printerr("Evasive Growth callback: _owner est invalide.")
		return
	_owner.stats.health_max += _life_stats.evasive_growth_increase_max_hp

func _vital_pulse_timer_timeout() -> void:
	# [VITAL PULSE]
	var targets: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
	print(targets)
	if targets.is_empty():
		return
	var max_hp: int = _owner.stats.health_max
	var percent: float = _life_stats.vital_pulse_damage_percent
	var damage: float = max_hp * (percent / 100.0)
	if damage <= 0:
		return
	for target in targets:
		if target != null and is_instance_valid(target):
			_owner.direct_attack(target, damage, Utils.DamageType.PHYSICAL)

func _on_tainted_blood_timer_timeout() -> void:
	# [TAINTED BLOOD]
	
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null or not is_instance_valid(target):
		return

	var max_hp: int = _owner.stats.health_max
	var current_hp: int = _owner.stats.health
	var lost_hp: int = max_hp - current_hp
	
	if lost_hp <= 0:
		return 

	var percent: float = _life_stats.tainted_blood_lost_hp_percent
	var stacks: int = int(float(lost_hp) * (percent / 100.0))
	
	if stacks <= 0:
		return
	var stack_type: Utils.StackType
	if Utils.rng.randi() % 2 == 0:
		stack_type = Utils.StackType.POISON
	else:
		stack_type = Utils.StackType.IGNITE
		stacks *= 5
		
	_owner.inflict_condition_stacks(target, stacks, stack_type)
