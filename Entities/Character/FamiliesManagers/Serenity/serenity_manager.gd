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
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()
	_add_action_modifiers()
	_add_stat_modifiers()
	_regen_tick_timer.start()
	

func stop() -> void:
	_regen_tick_timer.stop()
	_clear_stat_modifiers()
	_remove_action_modifiers()
	for timer in _optional_timers:
		timer.stop()
	_clear_optional_timers()
	
	
# ============================== Private functions ==============================

#region optional timer


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
	# [PURIFYING FLAME]
	if _serenity_stats.purifying_flame_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.purifying_flame_period, _purifying_flame_timer_timeout, true))

#endregion

#region stat modifier
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
		
	# [MIRACLE LIGHT]
	if _serenity_stats.miracle_light_activated:
		var crit_bonus = _serenity_stats.miracle_light_crit_chance
		
		# 1. Bonus pour HEAL
		var heal_mod := StatModifier.new()
		heal_mod.id = "Miracle Light"
		heal_mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		heal_mod.action_type = Utils.ActionType.UTILITY_HEAL
		heal_mod.calc_type = StatModifier.CalcType.ADD
		heal_mod.value = crit_bonus
		heal_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(heal_mod)
		
		# 2. Bonus pour CLEANSE
		var cleanse_mod := StatModifier.new()
		cleanse_mod.id = "Miracle Light"
		cleanse_mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		cleanse_mod.action_type = Utils.ActionType.UTILITY_CLEANSE
		cleanse_mod.calc_type = StatModifier.CalcType.ADD
		cleanse_mod.value = crit_bonus
		cleanse_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(cleanse_mod)
		
		# 3. Bonus pour REGEN
		var regen_mod := StatModifier.new()
		regen_mod.id = "Miracle Light"
		regen_mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		regen_mod.action_type = Utils.ActionType.STACK_REGEN
		regen_mod.calc_type = StatModifier.CalcType.ADD
		regen_mod.value = crit_bonus
		regen_mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(regen_mod)
		
func _clear_stat_modifiers() -> void:
	# [GRACEFUL STEP]
	if _serenity_stats.graceful_step_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Graceful Step"
		_owner.stats_manager.unregister_modifier(mod)
	
	# [MIRACLE LIGHT]
	if _serenity_stats.miracle_light_activated:
		var heal_mod := StatModifier.new()
		heal_mod.id = "Miracle Light"
		heal_mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		heal_mod.action_type = Utils.ActionType.UTILITY_HEAL
		_owner.stats_manager.unregister_modifier(heal_mod)
		
		var cleanse_mod := StatModifier.new()
		cleanse_mod.id = "Miracle Light"
		cleanse_mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		cleanse_mod.action_type = Utils.ActionType.UTILITY_CLEANSE 
		_owner.stats_manager.unregister_modifier(cleanse_mod)
		
		var regen_mod := StatModifier.new()
		regen_mod.id = "Miracle Light"
		regen_mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		regen_mod.action_type = Utils.ActionType.STACK_REGEN
		_owner.stats_manager.unregister_modifier(regen_mod)
#endregion

#region action modifier

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
		
#endregion

#region others card

#endregion

# ============================== Callbacks functions ==============================

func _holy_touch_timer_timeout() -> void: 
	# [HOLY TOUCH]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null: return
	_owner.heal(target, _serenity_stats.holy_touch_amount, "Holy Touch")

func _life_spring_timer_timeout() -> void:
	# [LIFE SPRING]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null: 
		return
	_owner.inflict_condition_stacks(target, _serenity_stats.life_spring_regen_amount, Utils.StackType.REGEN, "Life Spring")

func _on_regen_tick_timer_timeout() -> void:
	var heal_amount: float = _owner.stats.regen_stacks
	if heal_amount > 0:
		_owner.heal(_owner, heal_amount, "Regen")
	
func _purifying_flame_timer_timeout() -> void:
	# [PURIFYING FLAME]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)
	if target == null: 
		return
	var amount_to_cleanse: float = _serenity_stats.purifying_flame_cleanse_amount
	_owner.cleanse(target, amount_to_cleanse, "Purifying Flame")
	
func _on_dodge_graceful_step(_cb_vars: Dictionary) -> void:
	# [GRACEFUL STEP]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target != null:
		_owner.inflict_condition_stacks(target, _serenity_stats.graceful_step_regen, Utils.StackType.REGEN, "Graceful Step")
