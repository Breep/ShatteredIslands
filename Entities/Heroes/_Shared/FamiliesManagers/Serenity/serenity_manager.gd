class_name SerenityManager
extends FamilyManager

# ============================== Constant ==============================

# ============================== Private variables ==============================

var _divine_intervention_triggered: bool = false

var _serenity_stats: FamilySerenityStats # Ref to the owner heal stats

#[REGEN]
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
	_add_stat_modifiers()
	_regen_tick_timer.start()
	
	# [DIVINE INTERVENTION]
	if _serenity_stats.divine_intervention_activated:
		_divine_intervention_triggered = false
		var allies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally in allies:
			if ally == null or not is_instance_valid(ally): continue
			if not ally.stats.health_changed.is_connected(_on_divine_intervention_health_changed):
				ally.stats.health_changed.connect(_on_divine_intervention_health_changed.bind(ally))

	# [REJUVENATIVE FAITH]
	if _serenity_stats.rejuvenative_faith_activated:
		if not _owner.interaction_received.is_connected(_on_interaction_received_rejuvenative_faith):
			_owner.interaction_received.connect(_on_interaction_received_rejuvenative_faith)

	# [WARM AURA]
	if _serenity_stats.warm_aura_activated:
		if not _owner.action_done.is_connected(_on_action_done_warm_aura):
			_owner.action_done.connect(_on_action_done_warm_aura)

	# [OVERFLOWING LIGHT]
	if _serenity_stats.overflowing_light_activated:
		if not _owner.action_overhealed.is_connected(_on_action_overhealed_overflowing_light):
			_owner.action_overhealed.connect(_on_action_overhealed_overflowing_light)

	# [CORRUPTED LIGHT]
	if _serenity_stats.serenity_corrupted_light_activated:
		if not _owner.action_done.is_connected(_on_action_done_corrupted_light):
			_owner.action_done.connect(_on_action_done_corrupted_light)
			
	# [LIGHT COLLECTOR]
	if _serenity_stats.light_collector_activated:
		_apply_light_collector()
		
	# [DIVINE REGENERATOR]
	if _serenity_stats.divine_regenerator_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		action_modifier.id = "Divine Regenerator"
		action_modifier.is_one_time_effect = false
		action_modifier.before_action_logic_callback = _on_before_inflict_condition_divine_regenerator
		_owner.action_modifiers_manager.register_modifier(action_modifier)

	
func stop() -> void:
	_regen_tick_timer.stop()
	_stop_divine_intervention()
	_stop_rejuvenative_faith()
	_stop_warm_aura()
	_stop_overflowing_light()
	_stop_corrupted_light()
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
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.holy_touch_period, _holy_touch_timer_timeout, true))
	# [LIFE SPRING]
	if _serenity_stats.life_spring_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.life_spring_period, _life_spring_timer_timeout, true))
	# [PURIFYING FLAME]
	if _serenity_stats.purifying_flame_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.purifying_flame_period, _purifying_flame_timer_timeout, true))
	# [LUMINESCENT SURGE]
	if _serenity_stats.luminescent_surge_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _serenity_stats.luminescent_surge_period, _luminescent_surge_timer_timeout, true))

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

	# [RADIANT OVERFLOW]
	if _serenity_stats.serenity_radiant_overflow_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.HEAL
		action_modifier.id = "Radiant Overflow"
		action_modifier.is_one_time_effect = false
		action_modifier.before_action_logic_callback = _on_before_heal_radiant_overflow
		_owner.action_modifiers_manager.register_modifier(action_modifier)

#endregion

#region others card

func _stop_divine_intervention() -> void:
	if _serenity_stats.divine_intervention_activated:
		var allies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally in allies:
			if ally == null or not is_instance_valid(ally): continue
			if ally.stats.health_changed.is_connected(_on_divine_intervention_health_changed):
				ally.stats.health_changed.disconnect(_on_divine_intervention_health_changed)

func _stop_rejuvenative_faith() -> void:
	if _owner.interaction_received.is_connected(_on_interaction_received_rejuvenative_faith):
		_owner.interaction_received.disconnect(_on_interaction_received_rejuvenative_faith)

func _stop_warm_aura() -> void:
	if _owner.action_done.is_connected(_on_action_done_warm_aura):
		_owner.action_done.disconnect(_on_action_done_warm_aura)

func _stop_overflowing_light() -> void:
	if _owner.action_overhealed.is_connected(_on_action_overhealed_overflowing_light):
		_owner.action_overhealed.disconnect(_on_action_overhealed_overflowing_light)

func _stop_corrupted_light() -> void:
	if _owner.action_done.is_connected(_on_action_done_corrupted_light):
		_owner.action_done.disconnect(_on_action_done_corrupted_light)

# [LIGHT COLLECTOR]
func _apply_light_collector() -> void:
	if not _serenity_stats.light_collector_activated: return
	
	var count: int = 0
	if _player and _player.deck:
		count = _player.deck.get_unique_card_count(Family.FamilyType.SERENITY)
	else:
		push_warning("SerenityManager: _player or deck is null for Light Collector")
		return
	
	var amount_per_card: float = _serenity_stats.light_collector_regen_amount
	var total_regen: float = count * amount_per_card
	
	if total_regen > 0:
		var allies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for ally in allies:
			if ally != null and is_instance_valid(ally) and not ally.is_dead:
				_owner.inflict_condition_stacks(ally, total_regen, Utils.StackType.REGEN, "Light Collector")

#endregion

# ============================== Callbacks functions ==============================

#region ============== HOLY TOUCH ==================
func _holy_touch_timer_timeout() -> void:
	# [HOLY TOUCH]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null: return
	_owner.heal(target, _serenity_stats.holy_touch_amount, "Holy Touch")
#endregion

#region ============== HOLY ORB ==================
func _holy_orb_timer_timeout() -> void:
	# [HOLY ORB]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	
	# If no enemy, we might want to cast it anyway?
	# If no enemy, maybe just cast forward? But Projectile NEEDS a target entity.
	
	# I will just target the closest enemy for now. If no enemy, it won't cast (common validation).
	if target == null: return
	
	var proj_stats := ProjectileStats.new()
	var damage: float = _serenity_stats.holy_orb_damage
	var heal: float = _serenity_stats.holy_orb_heal
	
	proj_stats.on_hit_logic_callbacks.append(_on_hit_holy_orb.bind(damage, heal))
	
	# ProjectileType.HOLY_ORB
	_owner.projectile_attack(target, Projectile.ProjectileType.HOLY_ORB, _owner._turret._projectile_spawn_point, proj_stats)

func _on_hit_holy_orb(cb_vars: Dictionary, damage: float, heal: float) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
	var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
	if target == null or not is_instance_valid(target): return
	
	if target.team != _owner.team:
		# Enemy: True Damage
		target.take_damage(damage, Utils.DamageType.MAGICAL, false, "Holy Orb", _owner)
	else:
		# Ally: Heal
		# Projectile doesn't heal by default
		target.take_heal(heal, false, "Holy Orb", _owner)

# [REJUVENATIVE FAITH]
func _on_interaction_received_rejuvenative_faith(_target: Entity, _source: Entity, action_type: Utils.ActionType, _action_id: StringName, value: float, _is_critical: bool) -> void:
	# Check if action is CLEANSE or DISPELL
	if action_type != Utils.ActionType.UTILITY_CLEANSE and action_type != Utils.ActionType.UTILITY_DISPELL:
		return
	
	if value <= 0: return
	var chance: float = _serenity_stats.rejuvenative_faith_chance
	
	if Utils.is_randomize_modifier_active(chance):
		var amount: float = _serenity_stats.rejuvenative_faith_amount
			
		# Apply Regen: amount per stack removed
		var regen_amount: float = value * amount
		if regen_amount > 0:
			_owner.inflict_condition_stacks(_owner, regen_amount, Utils.StackType.REGEN, "Rejuvenative Faith")

#endregion


#region ============== LIFE SPRING ==================
func _life_spring_timer_timeout() -> void:
	# [LIFE SPRING]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target == null:
		return
	_owner.inflict_condition_stacks(target, _serenity_stats.life_spring_regen_amount, Utils.StackType.REGEN, "Life Spring")
#endregion


#region ============== PURIFYING FLAME ==================
func _purifying_flame_timer_timeout() -> void:
	# [PURIFYING FLAME]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)
	if target == null:
		return
	var amount_to_cleanse: float = _serenity_stats.purifying_flame_cleanse_amount
	_owner.cleanse(target, amount_to_cleanse, "Purifying Flame")
#endregion


#region ============== GRACEFUL STEP ==================
func _on_dodge_graceful_step(_cb_vars: Dictionary) -> void:
	# [GRACEFUL STEP]
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	if target != null:
		_owner.inflict_condition_stacks(target, _serenity_stats.graceful_step_regen, Utils.StackType.REGEN, "Graceful Step")
#endregion

#region ============== LUMINESCENT SURGE ==================
func _luminescent_surge_timer_timeout() -> void:
	# [LUMINESCENT SURGE]
	var allies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
	# Filter invalid
	var valid_allies: Array[Entity] = []
	for ally in allies:
		if ally != null and is_instance_valid(ally) and not ally.is_dead:
			valid_allies.append(ally)
			
	# Sort by lowest HP percent
	valid_allies.sort_custom(func(a, b):
		var a_ratio = a.stats.health / a.stats.health_max
		var b_ratio = b.stats.health / b.stats.health_max
		return a_ratio < b_ratio
	)
	
	var count = min(_serenity_stats.luminescent_surge_target_count, valid_allies.size())
	
	for i in range(count):
		var ally = valid_allies[i]
		var max_hp = ally.stats.health_max
		var current_hp = ally.stats.health
		var lost_hp = max_hp - current_hp
		
		if lost_hp > 0:
			var heal_amount = lost_hp * (_serenity_stats.luminescent_surge_heal_percent / 100.0)
			if heal_amount > 0:
				_owner.heal(ally, heal_amount, "Luminescent Surge")
				
		# Apply Regen if below threshold
		if max_hp > 0:
			var hp_percent = (current_hp / max_hp) * 100.0
			if hp_percent < _serenity_stats.luminescent_surge_hp_threshold_percent:
				var regen = _serenity_stats.luminescent_surge_regen_amount
				if regen > 0:
					_owner.inflict_condition_stacks(ally, regen, Utils.StackType.REGEN, "Luminescent Surge")

#endregion


#region ============== WARM AURA ==================
func _on_action_done_warm_aura(_entity_ref: Entity, target: Entity, action_type: Utils.ActionType, _action_id: StringName, _value: float, _is_critical: bool) -> void:
	# Check if action is HEAL
	if action_type != Utils.ActionType.UTILITY_HEAL: return
	
	if target == null or not is_instance_valid(target) or target.is_dead: return
	
	# Check Chance
	var chance: float = _serenity_stats.warm_aura_chance
		
	if Utils.is_randomize_modifier_active(chance):
		var amount: float = _serenity_stats.warm_aura_cleanse_amount

		_owner.cleanse(target, amount, "Warm Aura")
#endregion

#region ============== OVERFLOWING LIGHT ==================
func _on_action_overhealed_overflowing_light(_entity_ref: Entity, target: Entity, amount: float) -> void:
	# [OVERFLOWING LIGHT]
	if amount <= 0: return
	if target == null or not is_instance_valid(target) or target.is_dead: return
	
	var shield_percent: float = _serenity_stats.overflowing_light_shield_percent
		
	if shield_percent > 0:
		var shield_amount = amount * (shield_percent / 100.0)
		if shield_amount > 0:
			_owner.inflict_condition_stacks(target, shield_amount, Utils.StackType.ARMOR, "Overflowing Light")
#endregion

#region ============== RADIANT OVERFLOW ==================
func _on_before_heal_radiant_overflow(cb_vars: Dictionary) -> void:
	# [RADIANT OVERFLOW]
	if not cb_vars.has(ActionModifier.VarType.TARGET) or not cb_vars.has(ActionModifier.VarType.HEAL_AMOUNT):
		return
		
	var target = cb_vars[ActionModifier.VarType.TARGET]
	if target == null or not is_instance_valid(target): return
	
	var regen_stacks: float = target.stats.regen_stacks
	if regen_stacks <= 0: return
	
	var ratio: float = _serenity_stats.serenity_radiant_overflow_ratio
	var increase_percent: float = regen_stacks * ratio
	
	cb_vars[ActionModifier.VarType.HEAL_AMOUNT] *= (1.0 + increase_percent)
#endregion

#region ============== CORRUPTED LIGHT ==================
func _on_action_done_corrupted_light(_entity_ref: Entity, _target: Entity, action_type: Utils.ActionType, _action_id: StringName, value: float, _is_critical: bool) -> void:
	# Check if action is HEAL
	if action_type != Utils.ActionType.UTILITY_HEAL: return
	if value <= 0: return

	var conversion_percent: float = _serenity_stats.serenity_corrupted_light_conversion_percent
	if conversion_percent <= 0: return
	
	var damage_amount: float = value * (conversion_percent / 100.0)
	if damage_amount <= 0: return
	
	var enemy = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if enemy == null:
		# print("DEBUG: Corrupted Light - No enemy found")
		return
		
	# print("DEBUG: Corrupted Light - Dealing ", damage_amount, " to ", enemy.name)
	_owner.direct_attack(enemy, damage_amount, Utils.DamageType.MAGICAL, "Corrupted Light")
#endregion

#region ============== REGEN ==================
#region ============== REGEN ==================
func _on_regen_tick_timer_timeout() -> void:
	# Tick Buffer (Expires old stacks)
	_owner.stats.tick_regen()
	
	# Apply Healing
	var regen_stacks: float = _owner.stats.regen_stacks
	if regen_stacks > 0:
		_owner.heal(_owner, regen_stacks, "Regen")
#endregion

#region ============== DIVINE INTERVENTION ==================
func _on_divine_intervention_health_changed(_new_val: float, ally: Entity) -> void:
	if _divine_intervention_triggered: return
	if ally == null or not is_instance_valid(ally): return
	
	var max_hp: float = ally.stats.health_max
	if max_hp <= 0: return
	
	var threshold_percent: float = _serenity_stats.divine_intervention_hp_threshold_percent
	var current_percent: float = (ally.stats.health / max_hp) * 100.0
	
	if current_percent <= threshold_percent:
		_divine_intervention_triggered = true
		
		# Full cleanse (using a very high value to ensure clearing everything)
		ally.cleanse(ally, 9999.0, "Divine Intervention")
		
		# Apply Regen
		var regen_amount: float = _serenity_stats.divine_intervention_regen_amount
		ally.inflict_condition_stacks(ally, regen_amount, Utils.StackType.REGEN, "Divine Intervention")
		
		# Optional: Disconnect signals to save performance since it's one-time
		var allies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		for a in allies:
			if a != null and is_instance_valid(a):
				if a.stats.health_changed.is_connected(_on_divine_intervention_health_changed):
					a.stats.health_changed.disconnect(_on_divine_intervention_health_changed)
#endregion

#region ============== DIVINE REGENERATOR ==================
func _on_before_inflict_condition_divine_regenerator(cb_vars: Dictionary) -> void:
	# [DIVINE REGENERATOR]
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE) or not cb_vars.has(ActionModifier.VarType.DURATION):
		return
		
	var stack_type = cb_vars[ActionModifier.VarType.STACK_TYPE]
	if stack_type != Utils.StackType.REGEN: return
	
	var bonus_duration: int = _serenity_stats.divine_regenerator_bonus_duration
	# print("DEBUG: Divine Regenerator triggered! Bonus: ", bonus_duration, " | Duration: ", cb_vars[ActionModifier.VarType.DURATION], " -> ", cb_vars[ActionModifier.VarType.DURATION] + bonus_duration)
	cb_vars[ActionModifier.VarType.DURATION] += bonus_duration
#endregion
