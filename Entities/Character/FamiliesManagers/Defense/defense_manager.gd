class_name DefenseManager
extends FamilyManager

# ============================== Signals ==============================

signal reflecto_belt_activated(damage_inc_percent: float, number_of_attacks: int)

# ============================== Private variables ==============================

var _defense_stats: FamilyDefenseStats # Ref to the owner defense stats

# [REFLECTO BELT]
var _reflecto_belt_accumulated_loss: int = 0
var _reflecto_belt_attacks_left: int = 0

# [LEGACY VARIABLES]
var _armor_lost_since_last_hedgehog_armor: int
var _armor_lost_since_last_rainbow_boots: int
var _mystical_shoulders_damage_reduced_percent: float
var _total_magical_damage_blocked: int

# ============================== Node base functions ==============================

func _ready() -> void:
	_defense_stats = _owner.families_stats.defense

# ============================== Public functions ==============================

func start() -> void:
	_lanch_on_battle_start_effects()
	_create_optional_timers()
	_add_action_modifiers()
	_add_stat_modifiers()
	
	# [REFLECTO BELT] Init
	_reflecto_belt_accumulated_loss = 0
	_reflecto_belt_attacks_left = 0
	
	# [PROTECTIVE DOME]
	if _defense_stats.protective_dome_activated:
		if not _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed_protective_dome):
			_owner.stats.armor_stacks_changed.connect(_on_owner_armor_stacks_changed_protective_dome)
		_update_protective_dome_modifier(_owner.stats.armor_stacks)
	
	# Timers start
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	
	_clear_action_modifiers()
	_clear_stat_modifiers()
	
	# [REFLECTO BELT] Nettoyage
	if _defense_stats.reflecto_belt_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")

	# [PROTECTIVE DOME] Déconnexion
	if _defense_stats.protective_dome_activated:
		if _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed_protective_dome):
			_owner.stats.armor_stacks_changed.disconnect(_on_owner_armor_stacks_changed_protective_dome)
		
		# On s'assure de retirer le bonus
		var mod := StatModifier.new()
		mod.id = "Protective Dome"
		mod.stat_type = EntityStats.StatType.RESISTANCE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		_owner.stats_manager.unregister_modifier(mod)


# --- Fonctions appelées par le système de dégâts ---

func get_reduced_damage_taken_from_armor(damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type == Utils.DamageType.POISON: 
		return damage
		
	var damage_reduction = min(damage, _owner.stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	
	# On réduit l'armure
	_owner.stats.armor_stacks -= damage_reduction
	
	# Logique des cartes sur perte d'armure
	_armor_lost_since_last_hedgehog_armor += damage_reduction
	_reflecto_belt_effect(damage_reduction)
	
	return damage_reduced


# ============================== Private functions ==============================

#region ===== BATTLE START EFFECTS =====
func _lanch_on_battle_start_effects() -> void:
	# [SHIELD RUSH]
	if _defense_stats.shield_rush_activated:
		if _owner != null and is_instance_valid(_owner):
			var amount: int = int(_defense_stats.shield_rush_amount)
			_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.ARMOR)
#endregion

#region ===== ACTION MODIFIERS =====
func _add_action_modifiers() -> void:
	# [EVASIVE BARRIER]
	if _defense_stats.evasive_barrier_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Barrier"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_evasive_barrier
		_owner.action_modifiers_manager.register_modifier(action_modifier)
#



func _clear_action_modifiers() -> void:
	# [EVASIVE BARRIER]
	if _defense_stats.evasive_barrier_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Barrier"
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
#
#endregion

#region ===== STAT MODIFIERS =====
func _add_stat_modifiers() -> void:
	# [EVASIVE BARRIER]
	if _defense_stats.evasive_barrier_activated:
		var mod := StatModifier.new()
		mod.id = "Evasive Barrier"
		mod.stat_type = EntityStats.StatType.DODGE
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _defense_stats.evasive_barrier_dodge_increase
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(mod)
		
	# [AVENGERS ASSEMBLE]
	if _defense_stats.avengers_assemble_activated:
		var mod := StatModifier.new()
		mod.id = "Avengers Assemble"
		mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		mod.action_type = Utils.ActionType.STACK_ARMOR 
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _defense_stats.avengers_assemble_crit_chance
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(mod)


func _clear_stat_modifiers() -> void:
	# [EVASIVE BARRIER]
	if _defense_stats.evasive_barrier_activated:
		var mod := StatModifier.new()
		mod.id = "Evasive Barrier"
		mod.stat_type = EntityStats.StatType.DODGE
		_owner.stats_manager.unregister_modifier(mod)
		
	# [AVENGERS ASSEMBLE]
	if _defense_stats.avengers_assemble_activated:
		var mod := StatModifier.new()
		mod.id = "Avengers Assemble"
		mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		mod.action_type = Utils.ActionType.STACK_ARMOR
		_owner.stats_manager.unregister_modifier(mod)
		
#endregion

#region ===== TIMERS =====
func _create_optional_timers() -> void:
	# [FORCE FIELD]
	if _defense_stats.force_field_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.force_field_period, _on_force_field_timer_timeout, true))
		
	# [ENERGY BARRIER]
	if _defense_stats.energy_barrier_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.energy_barrier_period, _on_energy_barrier_timer_timeout, true))
		
	# [MAGNETIC SIPHON]
	if _defense_stats.magnetic_siphon_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.magnetic_siphon_period, _on_magnetic_siphon_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region ===== OTHER LOGIC =====



func _reflecto_belt_effect(armor_lost: int) -> void:
	# [REFLECTO BELT]
	if not _defense_stats.reflecto_belt_activated:
		return
		
	_reflecto_belt_accumulated_loss += armor_lost
	var threshold: int = int(_defense_stats.reflecto_belt_shield_threshold)
	
	if threshold > 0 and _reflecto_belt_accumulated_loss >= threshold:
		_reflecto_belt_accumulated_loss -= threshold
		_activate_reflecto_belt_buff()


func _activate_reflecto_belt_buff() -> void:
	# [REFLECTO BELT]
	_reflecto_belt_attacks_left += _defense_stats.reflecto_belt_attacks_count
	
	var aa_modifier := AutoAttackModifier.new()
	aa_modifier.id = "Reflecto Belt"
	aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
	
	var percent: float = _defense_stats.reflecto_belt_damage_percent
	aa_modifier.damage_mult = 1.0 + (percent / 100.0)
	aa_modifier.on_attack_logic_callback = _on_attack_reflecto_belt_consumption
	
	_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)
	
	reflecto_belt_activated.emit(percent, _defense_stats.reflecto_belt_attacks_count)


# [PROTECTIVE DOME]
func _update_protective_dome_modifier(current_armor: int) -> void:
	var mod := StatModifier.new()
	mod.id = "Protective Dome"
	mod.stat_type = EntityStats.StatType.RESISTANCE
	mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	mod.tags = [StatModifier.TagType.CARD] 
	
	if current_armor > 0:
		mod.calc_type = StatModifier.CalcType.ADD 
		mod.value = _defense_stats.protective_dome_armor_percent
		_owner.stats_manager.register_modifier(mod)
	else:
		_owner.stats_manager.unregister_modifier(mod)

#endregion

# ============================== Callbacks functions ==============================

func _on_attack_reflecto_belt_consumption(cb_vars: Dictionary) -> void:
	# [REFLECTO BELT] - Consommation
	_reflecto_belt_attacks_left -= 1
	
	if _reflecto_belt_attacks_left <= 0:
		_reflecto_belt_attacks_left = 0
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")


func _on_force_field_timer_timeout() -> void:
	# [FORCE FIELD]
	if _owner == null or not is_instance_valid(_owner): return
	
	var max_hp: int = _owner.stats.health_max
	var current_hp: int = _owner.stats.health
	var lost_hp: int = max_hp - current_hp
	
	if lost_hp > 0:
		var percent: float = _defense_stats.force_field_lost_hp_percent
		var armor_gain: int = int(float(lost_hp) * (percent / 100.0))
		if armor_gain > 0:
			_owner.inflict_condition_stacks(_owner, armor_gain, Utils.StackType.ARMOR)


func _on_dodge_evasive_barrier(cb_vars: Dictionary) -> void:
	# [EVASIVE BARRIER]
	if _owner == null or not is_instance_valid(_owner): return
	
	var amount: float = _defense_stats.evasive_barrier_shield_gain
	_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.ARMOR)


func _on_energy_barrier_timer_timeout() -> void:
	# [ENERGY BARRIER]
	if _owner == null or not is_instance_valid(_owner):
		return
		
	var amount: int = int(_defense_stats.energy_barrier_shield_amount)
	_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.ARMOR)


func _on_owner_armor_stacks_changed_protective_dome(new_val: int) -> void:
	# [PROTECTIVE DOME]
	_update_protective_dome_modifier(new_val)
	
func _on_magnetic_siphon_timer_timeout() -> void:
	# [MAGNETIC SIPHON]
	if _owner == null or not is_instance_valid(_owner):
		return
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO)
	
	if target == null or not is_instance_valid(target):
		return	
	var highest_shield: int = target.stats.armor_stacks
	if highest_shield <= 0:
		return

	var percent: float = _defense_stats.magnetic_siphon_steal_percent
	var steal_amount: int = int(float(highest_shield) * (percent / 100.0))
	if steal_amount <= 0:
		return
		
	#TODO changer le steal quand il y aura des modificateurs a cet effet
	target.stats.armor_stacks -= steal_amount
	_owner.inflict_condition_stacks(_owner, steal_amount, Utils.StackType.ARMOR)
