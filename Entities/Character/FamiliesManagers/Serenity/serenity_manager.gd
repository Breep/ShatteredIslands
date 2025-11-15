class_name SerenityManager
extends FamilyManager

# ============================== Constant ==============================

const PACIFY_DAMAGE_REDUCTION_PERCENT: float = 50 # Percentage of damage reduction when pacified

# ============================== Private variables ==============================

var _serenity_stats: FamilySerenityStats # Ref to the owner heal stats

@onready var _regen_tick_timer: Timer = %RegenTickTimer

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_serenity_stats = _owner.families_stats.serenity


func start() -> void:
	for timer in _optional_timers:
		timer.start()
	_regen_tick_timer.start()
	_create_optional_timers()
	_add_action_modifiers()
	_add_stat_modifiers()
	

func stop() -> void:
	_clear_stat_modifiers()
	_remove_action_modifiers()
	_clear_optional_timers()
	_regen_tick_timer.stop()
	for timer in _optional_timers:
		timer.stop()
	
	
# ============================== Private functions ==============================
func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	
func _create_optional_timers() -> void:
	# [holy touch]
	if _serenity_stats.holy_touch_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self,_serenity_stats.holy_touch_period,_holy_touch_timer_timeout,true))
	# [LIFE SPRING]
	if _serenity_stats.life_spring_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.life_spring_period, _life_spring_timer_timeout, true))	

func _add_stat_modifiers() -> void:
	# [GRACEFUL STEP]
	if _serenity_stats.graceful_step_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _serenity_stats.graceful_step_increase_dodge
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Graceful Step"
		_owner.stats_manager.register_modifier(mod)
		
func _clear_stat_modifiers() -> void:
	# [GRACEFUL STEP]
	if _serenity_stats.graceful_step_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Graceful Step"
		_owner.stats_manager.unregister_modifier(mod)
		
func _add_action_modifiers() -> void:
	# [GRACEFUL STEP]
	if _serenity_stats.graceful_step_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Graceful Step"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_graceful_step
		_owner.action_modifiers_manager.register_modifier(action_modifier)

func _remove_action_modifiers() -> void:
	# [GRACEFUL STEP]
	if _serenity_stats.graceful_step_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Graceful Step"
		action_modifier.after_action_logic_callback = _on_dodge_graceful_step
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
		
# ============================== Callbacks functions ==============================

func _holy_touch_timer_timeout() -> void: 
	# [HOLY TOUCH]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null: return
	_owner.heal(target, _serenity_stats.holy_touch_amount)

func _life_spring_timer_timeout() -> void:
	# [LIFE SPRING]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null: 
		return
	_owner.inflict_condition_stacks(target, _serenity_stats.life_spring_regen_amount, Utils.StackType.REGEN)

func _on_regen_tick_timer_timeout() -> void:
	var heal_amount: int = _owner.stats.regen_stacks
	if heal_amount > 0:
		_owner.heal(_owner, heal_amount)
		
func _on_dodge_graceful_step(cb_vars: Dictionary) -> void:
	# [GRACEFUL STEP]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target != null:
		_owner.inflict_condition_stacks(target, _serenity_stats.graceful_step_regen, Utils.StackType.REGEN)
		
