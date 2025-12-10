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

# [AETHER REDIRECTOR]
var _aether_redirector_timer: Timer
var _aether_redirector_ready: bool = true

# [PROTECTIVE DOME]
var _protective_dome_modifier_active: bool = false


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
		_protective_dome_modifier_active = false
		if not _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.connect(_on_owner_armor_stacks_changed)
		_update_protective_dome_modifier(_owner.stats.armor_stacks)
	
	# [REACTIVE COVER]
	if _defense_stats.reactive_cover_activated:
		if not _owner.damage_taken.is_connected(_on_owner_damage_taken):
			_owner.damage_taken.connect(_on_owner_damage_taken)
	
	# [SHIELD THROW]
	if _defense_stats.shield_throw_activated:
		_shield_throw_accumulated = 0
		_shield_throw_last_armor = _owner.stats.armor_stacks
		_shield_throw_lock = false
		
		if not _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.connect(_on_owner_armor_stacks_changed)

	# [FIELD GENERATOR]
	if _defense_stats.defense_field_generator_activated:
		# Summon one at start
		_summon_field_generator()
		# Periodic
		_optional_timers.append(Utils.create_perpetual_timer(self, _defense_stats.defense_field_generator_summon_interval, _summon_field_generator, true))

	# [AETHER REDIRECTOR]
	if _defense_stats.aether_redirector_activated:
		_aether_redirector_ready = true
		_aether_redirector_timer = Timer.new()
		_aether_redirector_timer.one_shot = true
		_aether_redirector_timer.timeout.connect(_on_aether_redirector_cooldown_finished)
		add_child(_aether_redirector_timer)
		
	# [AETHER REDIRECTOR]
	if _defense_stats.aether_redirector_activated:
		_aether_redirector_ready = true
		_aether_redirector_timer = Timer.new()
		_aether_redirector_timer.one_shot = true
		_aether_redirector_timer.timeout.connect(_on_aether_redirector_cooldown_finished)
		add_child(_aether_redirector_timer)
		
		# Connect to FightingArea
		if _owner.fighting_area != null:
			if not _owner.fighting_area.projectile_spawned.is_connected(_on_projectile_spawned_aether_redirector):
				_owner.fighting_area.projectile_spawned.connect(_on_projectile_spawned_aether_redirector)


func stop() -> void:
	# [SHIELD THROW]
	if _defense_stats.shield_throw_activated:
		if _owner.stats.armor_stacks_changed.is_connected(_on_owner_armor_stacks_changed):
			_owner.stats.armor_stacks_changed.disconnect(_on_owner_armor_stacks_changed)
	
	# [REFLECTO BELT] Nettoyage
	if _defense_stats.reflecto_belt_activated and _is_reflecto_belt_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Reflecto Belt")
		
	# [REACTIVE COVER]
	if _defense_stats.reactive_cover_activated:
		if _owner.damage_taken.is_connected(_on_owner_damage_taken):
			_owner.damage_taken.disconnect(_on_owner_damage_taken)
	
	# [AETHER REDIRECTOR]
	if _aether_redirector_timer != null:
		_aether_redirector_timer.queue_free()
		_aether_redirector_timer = null
	# [AETHER REDIRECTOR]
	if _aether_redirector_timer != null:
		_aether_redirector_timer.queue_free()
		_aether_redirector_timer = null
	
	if _owner.fighting_area != null:
		if _owner.fighting_area.projectile_spawned.is_connected(_on_projectile_spawned_aether_redirector):
			_owner.fighting_area.projectile_spawned.disconnect(_on_projectile_spawned_aether_redirector)


	_clear_optional_timers()

# --- Fonctions appelées par le système de dégâts ---

func get_reduced_damage_taken_from_armor(damage: float, damage_type: Utils.DamageType) -> float:
	if damage_type == Utils.DamageType.POISON:
		# [TOXIC FILTRATION LAYER]
		if _defense_stats.toxic_filtration_layer_activated:
			var efficiency: float = _defense_stats.toxic_filtration_layer_efficiency
			# We limit the blocking by the efficiency
			# Usual implementation for "Shield block poison with X% value":
			# It means X% of the incoming poison damage is treated as blockable by armor.
			
			var amount_blockable = damage * (efficiency / 100.0)
			var amount_bypassing = damage - amount_blockable
			
			var damage_reduction = min(amount_blockable, _owner.stats.armor_stacks)
			var damage_after_armor = amount_blockable - damage_reduction
			
			_owner.stats.armor_stacks -= damage_reduction
			
			# Logic cards on armor loss (Reflecto Belt etc)
			if damage_reduction > 0:
				_reflecto_belt_effect(damage_reduction)
			
			return amount_bypassing + damage_after_armor
			
		return damage
		
	var damage_reduction = min(damage, _owner.stats.armor_stacks)
	var damage_reduced = damage - damage_reduction
	
	# [ABSORPTION MATRIX]
	var consume_armor = true
	if _defense_stats.absorption_matrix_activated:
		if Utils.is_randomize_modifier_active(_defense_stats.absorption_matrix_chance):
			consume_armor = false
			# Potential feedback here
	
	if consume_armor:
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
	if _reflecto_belt_accumulated_loss >= _defense_stats.reflecto_belt_shield_threshold:
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
		if not _protective_dome_modifier_active:
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = _defense_stats.protective_dome_armor_percent
			_owner.stats_manager.register_modifier(mod)
			_protective_dome_modifier_active = true
	else:
		if _protective_dome_modifier_active:
			_owner.stats_manager.unregister_modifier(mod)
			_protective_dome_modifier_active = false
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
		
# [REACTIVE COVER]
func _on_owner_damage_taken(_entity: Entity, damage: float, _damage_type: Utils.DamageType, _is_crit: bool, _is_blocked: bool) -> void:
	if damage <= 0: return
	
	var chance: float = _defense_stats.reactive_cover_chance
	if Utils.is_randomize_modifier_active(chance):
		_owner.inflict_condition_stacks(_owner, _defense_stats.reactive_cover_shield_amount, Utils.StackType.ARMOR, "Reactive Cover")

# [AETHER REDIRECTOR]
# [AETHER REDIRECTOR]
func _on_projectile_spawned_aether_redirector(source: Entity, target: Entity, projectile_type: Projectile.ProjectileType, _modifiers: Array[Projectile.ProjectileEffect], projectile: Projectile) -> void:
	if not _aether_redirector_ready: return
	if projectile_type == Projectile.ProjectileType.AUTO_ATTACK: return # Ignore AA
	
	# Check if target is an ally (and not self)
	if target == _owner or target.team != _owner.team: return
	
	# Redirect
	print("[AETHER REDIRECTOR] Redirecting projectile from ", target.entity_name, " to self")
	
	_aether_redirector_ready = false
	_aether_redirector_timer.start(_defense_stats.aether_redirector_period)
	
	projectile.set_target(_owner)
	
	# Gain Shield
	print("[AETHER REDIRECTOR] Applying shield: ", _defense_stats.aether_redirector_shield_amount)
	_owner.inflict_condition_stacks(_owner, _defense_stats.aether_redirector_shield_amount, Utils.StackType.ARMOR, "Aether Redirector")


func _on_aether_redirector_cooldown_finished() -> void:
	_aether_redirector_ready = true


# [FIELD GENERATOR]
func _summon_field_generator() -> void:
	if _owner == null or not is_instance_valid(_owner): return
	
	var summon_pos = _owner.global_position
	# Slight offset maybe?
	summon_pos += Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
	
	var mods: Dictionary = {
		Entity.FieldGeneratorModifier.SHIELD_AMOUNT: _defense_stats.defense_field_generator_shield_amount,
		Entity.FieldGeneratorModifier.SHIELD_INTERVAL: _defense_stats.defense_field_generator_shield_interval,
		Entity.FieldGeneratorModifier.INITIAL_SHIELD: _defense_stats.defense_field_generator_initial_shield,
		Entity.FieldGeneratorModifier.MAX_HEALTH: _defense_stats.defense_field_generator_max_health,
		Entity.FieldGeneratorModifier.TARGET_COUNT: _defense_stats.defense_field_generator_target_count
	}
	
	_owner.summon_entity(Entity.EntityType.FIELD_GENERATOR, summon_pos, mods)
