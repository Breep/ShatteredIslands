class_name NecroManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _necro_stats: FamilyNecroStats # Ref to the owner necro stats

# ============================== Local nodes ==============================

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
	pass


func _clear_action_modifiers() -> void:
	pass
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


#region ===== PUTRID TOUCH =====
func _on_putrid_touch_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	_owner.inflict_condition_stacks(target, _necro_stats.necro_putrid_touch_stacks, Utils.StackType.NECROSIS, "Putrid Touch")
#endregion

#region ===== RAISE DEAD =====
func _on_raise_dead_timer_timeout() -> void:
	pass
#endregion
