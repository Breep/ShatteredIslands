class_name NecroManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _necro_stats: FamilyNecroStats # Ref to the owner necro stats

# ============================== Local nodes ==============================

@onready var _necro_tick_timer: Timer = %NecroTickTimer 

# ============================== Node base functions ==============================

func _ready() -> void:
	_necro_stats = _owner.families_stats.necro

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	_on_battle_start()
	_add_stat_modifiers()
	_add_action_modifiers()
	_add_stack_modifiers()
	


func stop() -> void:
	_clear_stack_modifiers()
	_clear_action_modifiers() 
	for spell in _optional_spells:
		spell.queue_free()
	_clear_optional_timers()

# ============================== Private functions ==============================

#region on battle start
func _on_battle_start() -> void:
	pass
#endregion

#region optional timer
func _create_optional_timers() -> void:
	
	# [PUTRID TOUCH]
	if _necro_stats.necro_putrid_touch_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _necro_stats.necro_putrid_touch_period, _on_putrid_touch_timer_timeout, true))

func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region stats modifier
func _add_stat_modifiers() -> void:
	return
#endregion

#region actions modifier (NECROSIS LOGIC HERE)
func _add_action_modifiers() -> void:
	# [NECROSIS MECHANIC]
	if true: 
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.HEAL 
		action_modifier.id = "Necrosis Anti-Heal"
		action_modifier.tags = [ActionModifier.TagType.CARD]
		action_modifier.is_one_time_effect = false
		action_modifier.before_action_logic_callback = _on_before_heal_necrosis
		_owner.action_modifiers_manager.register_modifier(action_modifier)


func _clear_action_modifiers() -> void:
	# [NECROSIS MECHANIC]
	if true:
		var action_modifier := ActionModifier.new()
		action_modifier.id = "Necrosis Anti-Heal"
		action_modifier.action_type = ActionModifier.ActionType.HEAL
		action_modifier.before_action_logic_callback = _on_before_heal_necrosis
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
#endregion

#region on inflict stacks modifier
func _add_stack_modifiers() -> void:
	pass

func _clear_stack_modifiers() -> void:
	pass
#endregion

#region others cards
func _lanch_optional_spells() -> void:
	## [BONE SPIKE]
	#if _necro_stats.necro_bone_spike_activated:
		#var spell_modifier: Dictionary = {
			#Spell.BoneSpikeModifier.DAMAGE: _necro_stats.necro_bone_spike_damage,
			#Spell.BoneSpikeModifier.STUN_DURATION: _necro_stats.necro_bone_spike_stun
		#}
		#_owner.cast_spell(_owner, Spell.Type.BONE_SPIKE, spell_modifier)
	return
#endregion

# ============================== Callbacks functions ==============================

#region ===== NECROSIS LOGIC =====
# [NECROSIS]
func _on_before_heal_necrosis(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.TARGET): return
	var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
	if target != _owner: return
	if _owner.stats.necrosis_stacks <= 0: return
	var stack_count: int = _owner.stats.necrosis_stacks
	var reduction_percentage: float = float(stack_count) * 0.10
	if reduction_percentage > 1.0: reduction_percentage = 1.0
	var key_amount = ActionModifier.VarType.STACK_VALUE
	if cb_vars.has(key_amount):
		var current_heal = cb_vars[key_amount]
		var new_heal = current_heal * (1.0 - reduction_percentage)
		print("--------------------------------------------------")
		print("[NECROSIS DEBUG] Target: ", _owner.name)
		print("[NECROSIS DEBUG] Stacks count: ", stack_count)
		print("[NECROSIS DEBUG] Reduction: ", reduction_percentage * 100, "%")
		print("[NECROSIS DEBUG] Heal BEFORE: ", current_heal)
		print("[NECROSIS DEBUG] Heal AFTER: ", new_heal)
		print("--------------------------------------------------")
		cb_vars[key_amount] = new_heal
		_owner.stats.necrosis_stacks = max(0, _owner.stats.necrosis_stacks - 1)
#endregion

#region ===== PUTRID TOUCH =====
func _on_putrid_touch_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	_owner.inflict_condition_stacks(target, _necro_stats.necro_putrid_touch_stacks, Utils.StackType.NECROSIS, "Putrid Touch")
	print("[NECROSIS DEBUG putrid]")
#endregion

#region ===== RAISE DEAD =====
func _on_raise_dead_timer_timeout() -> void:
	pass
#endregion
