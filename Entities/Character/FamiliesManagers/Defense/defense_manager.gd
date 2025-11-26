class_name DefenseManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _defense_stats: FamilyDefenseStats # Ref to the owner defense stats

# [REFLECTO BELT]
var _reflecto_belt_accumulated_loss: float = 0
var _reflecto_belt_attacks_left: int = 0
var _is_reflecto_belt_activated: bool = false

# [SHIELD THROW]
var _shield_throw_accumulated: int = 0
var _shield_throw_last_armor: int = 0
var _shield_throw_lock: bool = false # Pour éviter que le gain du bouclier qui revient ne déclenche un nouveau lancer


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
	_is_reflecto_belt_activated = false
	
	# [PROTECTIVE DOME]
	if _defense_stats.protective_dome_activated:
		if not _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.connect(_on_owner_armor_stacks_changed)
		_update_protective_dome_modifier(_owner.stats.armor_stacks)
	
	# [SHIELD THROW]
	if _defense_stats.shield_throw_activated:
		_shield_throw_accumulated = 0
		_shield_throw_last_armor = _owner.stats.armor_stacks
		_shield_throw_lock = false
		
		if not _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.connect(_on_owner_armor_stacks_changed)


func stop() -> void:
	# [SHIELD THROW]
	if _defense_stats.shield_throw_activated:
		if _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.disconnect(_on_owner_armor_stacks_changed)
	
		# [PROTECTIVE DOME] Déconnexion
	if _defense_stats.protective_dome_activated:
		if _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.disconnect(_on_owner_armor_stacks_changed)
		
		# On s'assure de retirer le bonus
		var mod := StatModifier.new()
		mod.id = "Protective Dome"
		mod.stat_type = EntityStats.StatType.RESISTANCE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		_owner.stats_manager.unregister_modifier(mod)
	
	# [REFLECTO BELT] Nettoyage
	if _defense_stats.reflecto_belt_activated and _is_reflecto_belt_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")
	
	_clear_action_modifiers()
	_clear_stat_modifiers()
	_clear_optional_timers()

# --- Fonctions appelées par le système de dégâts ---

func get_reduced_damage_taken_from_armor(damage: float, damage_type: Utils.DamageType) -> float:
	if damage_type == Utils.DamageType.POISON: 
		return damage
		
	var damage_reduction = min(damage, _owner.stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	
	# On réduit l'armure
	_owner.stats.armor_stacks -= damage_reduction
		
	# Logique des cartes sur perte d'armure
	_reflecto_belt_effect(damage_reduction)
	
	return damage_reduced


# ============================== Private functions ==============================

#region ===== BATTLE START EFFECTS =====
func _lanch_on_battle_start_effects() -> void:
	# [SHIELD RUSH]
	if _defense_stats.shield_rush_activated:
		if _owner != null and is_instance_valid(_owner):
			var amount: int = int(_defense_stats.shield_rush_amount)
			_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.ARMOR, "Shield Rush")
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
		
	# [AEGIS RESONATOR]
	if _defense_stats.aegis_resonator_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.aegis_resonator_period, _on_aegis_resonator_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region ===== OTHER LOGIC =====
# [REFLECTO BELT]
func _reflecto_belt_effect(armor_lost: int) -> void:
	if not _defense_stats.reflecto_belt_activated: return
	_reflecto_belt_accumulated_loss += armor_lost
	if  _reflecto_belt_accumulated_loss >= _defense_stats.reflecto_belt_shield_threshold:
		_reflecto_belt_accumulated_loss -= _defense_stats.reflecto_belt_shield_threshold
		_reflecto_belt_attacks_left += _defense_stats.reflecto_belt_attacks_count
		if _is_reflecto_belt_activated == false:
			_activate_reflecto_belt_buff()


# [REFLECTO BELT]
func _activate_reflecto_belt_buff() -> void:
	_is_reflecto_belt_activated = true
	var aa_modifier := AutoAttackModifier.new()
	aa_modifier.id = "Reflecto Belt"
	aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
	var percent: float = _defense_stats.reflecto_belt_damage_percent
	aa_modifier.damage_mult = 1.0 + (percent / 100.0)
	aa_modifier.is_one_time_effect = false
	aa_modifier.on_attack_logic_callback = _on_attack_reflecto_belt_consumption
	_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)


# [PROTECTIVE DOME]
func _update_protective_dome_modifier(current_armor: float) -> void:
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

#region ===== SHIELD THROW =====
# [SHIELD THROW] - Surveillance
func _check_shield_throw_on_armor_gain(new_val: int) -> void:
	var gain: int = new_val - _shield_throw_last_armor
	_shield_throw_last_armor = new_val
	
	if gain <= 0: return
		
	_shield_throw_accumulated += gain
	var threshold: int = int(_defense_stats.shield_throw_threshold)
	
	if threshold > 0 and _shield_throw_accumulated >= threshold:
		while _shield_throw_accumulated >= threshold:
			_shield_throw_accumulated -= threshold
			_trigger_shield_throw_start()

# [SHIELD THROW] - Tir
func _trigger_shield_throw_start() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null: return
	
	var proj_stats := ProjectileStats.new()
	
	proj_stats.is_bouncing = true
	proj_stats.bounces_remaining = 20 
	
	proj_stats.on_hit_logic_callbacks.append(_on_hit_shield_throw)
	
	var p_type = Projectile.ProjectileType.AUTO_ATTACK 
	if "SHIELD_THROW" in Projectile.ProjectileType: p_type = Projectile.ProjectileType.SHIELD_THROW
	
	_owner.projectile_attack(target, p_type, _owner._turret._projectile_spawn_point, proj_stats)
#endregion

# ============================== Callbacks functions ==============================

# [REFLECTO BELT]
func _on_attack_reflecto_belt_consumption(_cb_vars: Dictionary) -> void:
	_reflecto_belt_attacks_left -= 1
	
	if _reflecto_belt_attacks_left <= 0:
		_reflecto_belt_attacks_left = 0
		_is_reflecto_belt_activated = false
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")


func _on_force_field_timer_timeout() -> void:
	# [FORCE FIELD]
	if _owner == null or not is_instance_valid(_owner): return
	
	var max_hp: float = _owner.stats.health_max
	var current_hp: float = _owner.stats.health
	var lost_hp: float = max_hp - current_hp
	
	if lost_hp > 0:
		var percent: float = _defense_stats.force_field_lost_hp_percent
		var armor_gain: int = int(float(lost_hp) * (percent / 100.0))
		if armor_gain > 0:
			_owner.inflict_condition_stacks(_owner, armor_gain, Utils.StackType.ARMOR, "Force Field")


func _on_dodge_evasive_barrier(_cb_vars: Dictionary) -> void:
	# [EVASIVE BARRIER]
	if _owner == null or not is_instance_valid(_owner): return
	
	var amount: float = _defense_stats.evasive_barrier_shield_gain
	_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.ARMOR, "Evasive Barrier")


func _on_energy_barrier_timer_timeout() -> void:
	# [ENERGY BARRIER]
	if _owner == null or not is_instance_valid(_owner):
		return
		
	var amount: int = int(_defense_stats.energy_barrier_shield_amount)
	_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.ARMOR, "Energy Barrier")


func _on_owner_armor_stacks_changed(new_val: int) -> void:
	# [PROTECTIVE DOME]
	if _defense_stats.protective_dome_activated:
		_update_protective_dome_modifier(new_val)
		
	# [SHIELD THROW]
	if _defense_stats.shield_throw_activated:
		_check_shield_throw_on_armor_gain(new_val)


func _on_magnetic_siphon_timer_timeout() -> void:
	# [MAGNETIC SIPHON]
	if _owner == null or not is_instance_valid(_owner):
		return
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO)
	
	if target == null or not is_instance_valid(target):
		return	
	var highest_shield: float = target.stats.armor_stacks
	if highest_shield <= 0:
		return

	var percent: float = _defense_stats.magnetic_siphon_steal_percent
	var steal_amount: float = highest_shield * percent / 100.0
	if steal_amount <= 0:
		return
		
	#TODO changer le steal quand il y aura des modificateurs a cet effet
	target.stats.armor_stacks -= steal_amount
	_owner.inflict_condition_stacks(_owner, steal_amount, Utils.StackType.ARMOR, "Magnetic Siphon")
	
func _on_aegis_resonator_timer_timeout() -> void:
	# [AEGIS RESONATOR]
	if _owner == null or not is_instance_valid(_owner):
		return

	var allies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
	if allies.is_empty():
		return
	var total_shield: float = _defense_stats.aegis_resonator_total_shield
	var ally_count: int = allies.size()
	
	var shield_per_ally: int = int(total_shield / float(ally_count))
	
	if shield_per_ally <= 0:
		return
	for ally in allies:
		if ally != null and is_instance_valid(ally):
			if ally == _owner:
				_owner.inflict_condition_stacks(_owner, shield_per_ally, Utils.StackType.ARMOR, "Resonator")
			else:
				ally.stats.armor_stacks += shield_per_ally


# [SHIELD THROW] - Impact
func _on_hit_shield_throw(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
	var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
	if target == null or not is_instance_valid(target): return
	
	var damage: float = _defense_stats.shield_throw_damage
	if damage > 0: 
		_owner.direct_attack(target, damage, Utils.DamageType.MAGICAL, "Shield Throw")
	
	var shield_return: float = _defense_stats.shield_throw_return_shield
	if shield_return > 0:
		_owner.inflict_condition_stacks(_owner, shield_return, Utils.StackType.ARMOR, "Shield Throw")
		_shield_throw_last_armor = _owner.stats.armor_stacks
		
