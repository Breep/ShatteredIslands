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
	for timer in _optional_timers:
		timer.start()
	_add_stat_modifiers()
	_add_action_modifiers()


func stop() -> void:
	_remove_action_modifiers()
	_clear_stat_modifiers()
	for timer in _optional_timers:
		timer.stop()


func get_increased_damage_taken_from_lost_hp(damage: float, _damage_type: Utils.DamageType) -> float:
	return damage

# [Revive]
func source_is_dead() -> void:
	if not _life_stats.revive_after_death_activated or _life_stats.revive_after_death_triggered:
		return
	
	_life_stats.revive_after_death_triggered = true
	_revive_timer.start()

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Poisonous hearth
	if _life_stats.poison_by_lost_hp_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.poison_by_lost_hp_period, _on_poison_by_lost_hp_timer_timeout))
	
	# Hearth of fire
	if _life_stats.fire_damage_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.fire_damage_period, _on_fire_damage_timer_timeout))
	
	if _life_stats.revive_after_death_activated:
		_revive_timer = Timer.new()
		_revive_timer.wait_time = _life_stats.revive_after_death_time
		_revive_timer.one_shot = true
		_revive_timer.timeout.connect(_on_revive_timer_timeout)
		add_child(_revive_timer)


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
		
func _clear_stat_modifiers() -> void:
	
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Evasive Growth"
		_owner.stats_manager.unregister_modifier(mod)
		
func _add_action_modifiers() -> void:
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Growth"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_evasive_growth
		_owner.action_modifiers_manager.register_modifier(action_modifier)

func _remove_action_modifiers() -> void:
	# [EVASIVE GROWTH]
	if _life_stats.evasive_growth_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Growth"
		action_modifier.after_action_logic_callback = _on_dodge_evasive_growth
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
		

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
