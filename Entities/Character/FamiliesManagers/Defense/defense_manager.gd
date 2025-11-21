class_name DefenseManager
extends FamilyManager

# ============================== Signals ==============================

signal reflecto_belt_activated(damage_inc_percent: float, number_of_attacks: int)

# ============================== Private variables ==============================

var _defense_stats: FamilyDefenseStats # Ref to the owner defense stats

# [REFLECTO BELT]
var _reflecto_belt_accumulated_loss: int = 0
var _reflecto_belt_attacks_left: int = 0

# [LEGACY VARIABLES NEEDED FOR LOGIC]
var _armor_lost_since_last_hedgehog_armor: int
var _armor_lost_since_last_rainbow_boots: int
var _mystical_shoulders_damage_reduced_percent: float

# ============================== Node base functions ==============================

func _ready() -> void:
	_defense_stats = _owner.families_stats.defense

# ============================== Public functions ==============================

func start() -> void:
	_lanch_on_battle_start_effects()
	_create_optional_timers()
	_add_action_modifiers()
	_add_stat_modifiers()
	
	# [REFLECTO BELT]
	_reflecto_belt_accumulated_loss = 0
	_reflecto_belt_attacks_left = 0
	
	# Timers start
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	
	_clear_action_modifiers()
	_clear_stat_modifiers()
	
	# [REFLECTO BELT]
	if _defense_stats.reflecto_belt_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")


# --- Fonctions appelées par le système de dégâts ---

func get_increased_damage_done_from_power_wrist(damage: float) -> float:
	if not _defense_stats.power_wrists_activated:
		return damage
	
	var power_stacks: int = floor(_owner.stats.armor_stacks as float / _defense_stats.power_wrists_armor_stacks)
	var damage_inc_percent: float = _defense_stats.power_wrists_damage_increase_percent * power_stacks
	var damage_inc: float = (damage * damage_inc_percent) / 100.0
	return damage + damage_inc


func get_reduced_damage_taken_from_mystical_shoulder(damage: int) -> int:
	if not _defense_stats.mystical_shoulders_activated:
		return damage
	
	var damage_reduction: int = ((damage as float * _mystical_shoulders_damage_reduced_percent) / 100.0) as int
	return damage - damage_reduction


func get_reduced_damage_taken_from_armor(damage: float, damage_type: Utils.DamageType) -> float:
	if damage_type == Utils.DamageType.POISON: 
		return damage
		
	var damage_reduction = min(damage, _owner.stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	
	# On retire l'armure
	_owner.stats.armor_stacks -= damage_reduction
	
	# Logique des cartes sur perte d'armure
	_armor_lost_since_last_hedgehog_armor += damage_reduction
	_rainbow_boots_effect(damage_reduction)
	_reflecto_belt_effect(damage_reduction)
	
	return damage_reduced


# ============================== Private functions ==============================

#region ===== BATTLE START EFFECTS =====
func _lanch_on_battle_start_effects() -> void:
	# [SHIELD RUSH]
	if _defense_stats.shield_rush_activated:
		if _owner != null and is_instance_valid(_owner):
			var amount: int = int(_defense_stats.shield_rush_amount)
			_owner.stats.armor_stacks += amount
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

	## [SMITH HAMMER]
	#if _defense_stats.smith_hammer_activated:
		#var action_modifier := ActionModifier.new()
		#action_modifier.action_type = ActionModifier.ActionType.DAMAGE_TAKEN
		#action_modifier.id = "Smith Hammer"
		#action_modifier.is_one_time_effect = false
		#action_modifier.after_action_logic_callback = _on_damage_taken_smith_hammer
		#_owner.action_modifiers_manager.register_modifier(action_modifier)


func _clear_action_modifiers() -> void:
	# [EVASIVE BARRIER]
	if _defense_stats.evasive_barrier_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Evasive Barrier"
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)

	## [SMITH HAMMER]
	#if _defense_stats.smith_hammer_activated:
		#var action_modifier := ActionModifier.new()
		#action_modifier.action_type = ActionModifier.ActionType.DAMAGE_TAKEN
		#action_modifier.id = "Smith Hammer"
		#_owner.action_modifiers_manager.unregister_modifier(action_modifier)
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
		
	# [PROTECTIVE DOME] (Conditionnel : nécessite connexion signal)
	if _defense_stats.protective_dome_activated:
		if not _owner.stats.armor_changed.is_connected(_on_owner_armor_changed_protective_dome):
			_owner.stats.armor_changed.connect(_on_owner_armor_changed_protective_dome)
		_update_protective_dome_modifier(_owner.stats.armor_stacks)


func _clear_stat_modifiers() -> void:
	# [EVASIVE BARRIER]
	if _defense_stats.evasive_barrier_activated:
		var mod := StatModifier.new()
		mod.id = "Evasive Barrier"
		mod.stat_type = EntityStats.StatType.DODGE
		_owner.stats_manager.unregister_modifier(mod)

	# [PROTECTIVE DOME]
	if _defense_stats.protective_dome_activated:
		if _owner.stats.armor_changed.is_connected(_on_owner_armor_changed_protective_dome):
			_owner.stats.armor_changed.disconnect(_on_owner_armor_changed_protective_dome)
		var mod := StatModifier.new()
		mod.id = "Protective Dome"
		mod.stat_type = EntityStats.StatType.RESISTANCE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		_owner.stats_manager.unregister_modifier(mod)
#endregion

#region ===== TIMERS =====
func _create_optional_timers() -> void:
	# [HEDGEHOG ARMOR]
	if _defense_stats.hedgehog_armor_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.hedgehog_armor_period, _on_hedgehog_armor_period_timeout, true))
	
	# [GLADIATOR HELMET]
	if _defense_stats.gladiator_helmet_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.gladiator_helmet_period, _on_gladiator_helmet_period_timeout, true))
		
	# [FORCE FIELD]
	if _defense_stats.force_field_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.force_field_period, _on_force_field_timer_timeout, true))
		
	# [ENERGY BARRIER]
	if _defense_stats.energy_barrier_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.energy_barrier_period, _on_energy_barrier_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region ===== OTHER LOGIC =====

func _gain_armor(armor_stacks: int) -> void:
	if _defense_stats.dual_shield_activated:
		var health_ratio: float = (_owner.stats.health as float / _owner.stats.health_max) * 100.0
		if health_ratio >= _defense_stats.dual_shield_health_threshold:
			armor_stacks *= 2
	
	_owner.take_condition_stacks(armor_stacks, Utils.StackType.ARMOR, false)


func _rainbow_boots_effect(armor_lost: int) -> void:
	if not _defense_stats.rainbow_boots_activated:
		return
	
	_armor_lost_since_last_rainbow_boots += armor_lost
	if _armor_lost_since_last_rainbow_boots < _defense_stats.rainbow_boots_armor_stacks:
		return
	
	var number_of_procs: int = floor(armor_lost as float / _defense_stats.rainbow_boots_armor_stacks as float)
	_armor_lost_since_last_rainbow_boots -= number_of_procs * _defense_stats.rainbow_boots_armor_stacks
	for i in number_of_procs:
		var effects: Array[Utils.StackType] = [Utils.StackType.POISON, Utils.StackType.IGNITE]
		var effect: Utils.StackType = effects[Utils.rng.randi_range(0, effects.size() - 1)]
		var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		_action_module.inflict_condition_stacks(target, 1, effect)


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


# [PROTECTIVE DOME] - Logique Update
func _update_protective_dome_modifier(current_armor: float) -> void:
	var mod := StatModifier.new()
	mod.id = "Protective Dome"
	mod.stat_type = EntityStats.StatType.RESISTANCE 
	mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	
	if current_armor > 0:
		mod.calc_type = StatModifier.CalcType.MULT
		var percent: float = _defense_stats.protective_dome_armor_percent
		mod.value = percent / 100.0
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.update_modifier(mod) # Ou register_modifier si besoin
	else:
		_owner.stats_manager.unregister_modifier(mod)
#endregion

# ============================== Callbacks functions ==============================

func _on_attack_reflecto_belt_consumption(_cb_vars: Dictionary) -> void:
	# [REFLECTO BELT]
	_reflecto_belt_attacks_left -= 1
	if _reflecto_belt_attacks_left <= 0:
		_reflecto_belt_attacks_left = 0
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")


func _on_hedgehog_armor_period_timeout() -> void:
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null: return
	var damage: int = (_armor_lost_since_last_hedgehog_armor * _defense_stats.hedgehog_armor_lost_armor_percent as float / 100.0) as int
	_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)
	_armor_lost_since_last_hedgehog_armor = 0


func _on_gladiator_helmet_period_timeout() -> void:
	_gain_armor(_defense_stats.gladiator_helmet_armor_stacks)


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
			_owner.stats.armor_stacks += armor_gain


func _on_dodge_evasive_barrier(_cb_vars: Dictionary) -> void:
	# [EVASIVE BARRIER]
	if _owner == null or not is_instance_valid(_owner): return
	var shield_amount: float = _defense_stats.evasive_barrier_shield_gain
	_owner.stats.armor_stacks += shield_amount


func _on_energy_barrier_timer_timeout() -> void:
	# [ENERGY BARRIER]
	if _owner == null or not is_instance_valid(_owner): return
	var amount: int = int(_defense_stats.energy_barrier_shield_amount)
	_owner.stats.armor_stacks += amount


func _on_damage_taken_smith_hammer(_cb_vars: Dictionary) -> void:
	# [SMITH HAMMER]
	var chance: float = _defense_stats.smith_hammer_chance
	if Utils.is_randomize_modifier_active(chance):
		var armor_amount: int = int(_defense_stats.smith_hammer_armor_stacks)
		_owner.inflict_condition_stacks(_owner, armor_amount, Utils.StackType.ARMOR)


func _on_owner_armor_changed_protective_dome(new_val: int) -> void:
	# [PROTECTIVE DOME]
	_update_protective_dome_modifier(new_val)
