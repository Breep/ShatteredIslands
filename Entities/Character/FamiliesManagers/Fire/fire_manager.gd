class_name FireManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _fire_stats: FamilyFireStats # Ref to the owner fire stats

# ============================== Local nodes ==============================

@onready var _ignite_timer: Timer = %IgniteTimer

@export_group("Configuration")
@export var _ignite_decay_percent: float = 20.0
@export var _ignite_percent_per_stack: float = 0.05

# ============================== Node base functions ==============================

func _ready() -> void:
	_fire_stats = _owner.families_stats.fire

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	_ignite_timer.start()
	_on_battle_start()
	_add_stat_modifiers()
	_add_action_modifiers()


func stop() -> void:
	_clear_stat_modifiers()
	_remove_action_modifiers()
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	for spell in _optional_spells:
		spell.queue_free()
	_ignite_timer.stop()


# ============================== Private functions ==============================
#region on battle start
#endregion

#region optional timer
#endregion

#region aa modifier
#endregion

#region stats modifier
#endregion

#region actions modifier
#endregion

#region others cards
#endregion
func _on_battle_start() -> void:
	# [nuke]
	if _fire_stats.nuke_activated:
		var targets: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
		for target: Entity in targets:
			_owner.inflict_condition_stacks(target,_fire_stats.nuke_ignite,Utils.StackType.IGNITE)
		

func _create_optional_timers() -> void:
	if _fire_stats.periodic_ignite_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.periodic_ignite_period, _on_periodic_ignite_timer_timeout, true))
	
	if _fire_stats.meteor_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.meteor_period, _on_meteor_timer_timeout, true))


func _lanch_optional_spells() -> void:
	pass

func _add_stat_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _fire_stats.dark_forest_increase_dodge
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Dark Forest"
		_owner.stats_manager.register_modifier(mod)
		
func _clear_stat_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Dark Forest"
		_owner.stats_manager.unregister_modifier(mod)
	
func _add_action_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Dark Forest"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_dark_forest
		_owner.action_modifiers_manager.register_modifier(action_modifier)

func _remove_action_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Dark Forest"
		action_modifier.after_action_logic_callback = _on_dodge_dark_forest
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	pass


func _on_periodic_ignite_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		_owner.inflict_condition_stacks(target, _fire_stats.periodic_ignite_stacks, Utils.StackType.IGNITE)


func _on_ignite_timer_timeout() -> void:
	if _owner.stats.ignite_stacks > 0:
		var percent: float = _ignite_percent_per_stack * _owner.stats.ignite_stacks
		_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.DamageType.MAGICAL)
	
	var decay: int = (_owner.stats.ignite_stacks * _ignite_decay_percent / 100.0) as int
	decay = clampi(decay, 1, decay)
	_owner.stats.ignite_stacks -= decay


func _on_meteor_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		var spell_modifier: Dictionary = {
			Spell.MeteorModifier.IGNITE_STACKS: _fire_stats.meteor_ignite_stacks,
			Spell.MeteorModifier.DAMAGE_PER_STACK: _fire_stats.meteor_damage_per_stack
		}
		_owner.cast_spell(target, Spell.Type.METEOR, spell_modifier)

func _on_dodge_dark_forest(_cb_vars: Dictionary) -> void:
	# [DARK FOREST]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		_owner.inflict_condition_stacks(target, _fire_stats.dark_forest_ignite_stacks, Utils.StackType.IGNITE)


 
