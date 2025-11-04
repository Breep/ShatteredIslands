class_name PoisonManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _poison_stats: FamilyPoisonStats # Ref to the owner poison stats

# ============================== Spells scenes ==============================

# ============================== Local scenes ==============================

@onready var _poison_tick_timer:Timer = %PoisonTickTimer

# ============================== Node base functions ==============================

func _ready() -> void:
	_poison_stats = _owner.families_stats.poison

# ============================== Public functions ==============================

func start() -> void:
	_lanch_optional_spells()
	_create_optional_timers()
	_add_attack_modifiers()
	_add_stat_modifiers()
	_add_fighting_events()
	_poison_tick_timer.start()


func stop() -> void:
	for spell in _optional_spells:
		spell.queue_free()
	_poison_tick_timer.stop()
	_clear_stat_modifiers()
	_clear_attack_modifiers()
	_clear_optional_timers()

# TODO Make a StackModifier like the AutoAttackModifier
func check_on_apply_poison_stack(target: Entity, stacks_number: int, stack_type: Utils.StackType) -> void:
	if stacks_number <= 0 or stack_type != Utils.StackType.POISON: return
	if target == null or target.is_queued_for_deletion(): return
	if _poison_stats.poison_hot_pot_activated and Utils.is_randomize_modifier_active(_poison_stats.poison_hot_pot_chance):
		_owner.inflict_condition_stacks(target, _poison_stats.poison_hot_pot_ignite_stacks, Utils.StackType.IGNITE)
	if _poison_stats.poison_rotting_milk_activated and Utils.is_randomize_modifier_active(_poison_stats.poison_rotting_milk_chance):
		_owner.inflict_condition_stacks(_owner, _poison_stats.poison_rotting_milk_regen_stacks, Utils.StackType.REGEN)
	if _poison_stats.poison_corrosion_activated:
		if Utils.rng.randi() % 2 == 0:
			target.stats.armor_stacks -= _poison_stats.poison_corrosion_buff_stacks
		else:
			target.stats.regen_stacks -= _poison_stats.poison_corrosion_buff_stacks

# ============================== Private functions ==============================

func _add_attack_modifiers() -> void:
	if _poison_stats.poison_rusty_dagger_activated:
		var aa_modifier := AutoAttackModifier.new()
		aa_modifier.id = "Rusty Dagger"
		aa_modifier.tags = [AutoAttackModifier.TagType.CARD]
		aa_modifier.on_attack_logic_callback = _on_rusty_dagger_logic_callback
		aa_modifier.is_one_time_effect = false
		_owner.auto_attack_modifier_registry.register_modifier(aa_modifier)

func _add_stat_modifiers() -> void:
	if _poison_stats.poison_antidote_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _poison_stats.poison_antidote_decrease
		mod.stat_type = EntityStats.StatType.POISON_RESISTANCE
		mod.id = "Antidote"
		_owner.stats_manager.register_modifier(mod)

func _add_fighting_events() -> void:
	if _poison_stats.poison_contagion_activated:
		_register_contagion()

func _clear_stat_modifiers() -> void:
	if _poison_stats.poison_antidote_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.POISON_RESISTANCE
		mod.id = "Antidote"
		_owner.stats_manager.unregister_modifier(mod)

func _clear_attack_modifiers() -> void:
	if _poison_stats.poison_rusty_dagger_activated:
		_owner.auto_attack_modifier_registry.unregister_modifier("Rusty Dagger")

func _create_optional_timers() -> void:
	# [POISON FLASK]
	if _poison_stats.poison_flask_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.poison_flask_period, _on_periodica_agaricus_timer_timeout, true))
	
	# [VENOMOUS DARTS]
	if _poison_stats.poison_venomous_darts_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.poison_venomous_darts_period, _on_venomous_darts_timer_timeout, true))
	
	# [TIDE OF CORRUPTION]
	if _poison_stats.poison_tide_of_corruption_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.poison_tide_of_corruption_period, _on_tide_of_corruption_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

# Handle poison stacks and damage on _owner
func _on_poison_tick_timer_timeout() -> void:
	if not multiplayer.is_server(): return
	if _owner.stats.poison_stacks > 0:
		_owner.take_damage(_owner.stats.poison_stacks, Utils.DamageType.POISON, false)


func _on_periodica_agaricus_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var poison_stacks = _poison_stats.poison_flask_stacks
	_action_module.inflict_condition_stacks(target, poison_stacks, Utils.StackType.POISON)


func _on_rusty_dagger_logic_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.PROJECTILE_STATS): return
	var proj_stats: ProjectileStats = cb_vars[AutoAttackModifier.VarType.PROJECTILE_STATS]
	if Utils.is_randomize_modifier_active(_poison_stats.poison_rusty_dagger_chance):
		proj_stats.poison_stacks += _poison_stats.poison_rusty_dagger_stacks


#region VENOMOUS DARTS
func _on_venomous_darts_timer_timeout() -> void:
	for i in _poison_stats.poison_venomous_darts_darts_number:
		var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		if target == null: return
		var projectile_stats := ProjectileStats.new()
		projectile_stats.on_hit_logic_callbacks.append(_on_hit_venomous_logic_callback)
		_owner.projectile_attack(target, Projectile.ProjectileType.VENOMOUS_DART, _owner._turret._projectile_spawn_point, projectile_stats)


func _on_hit_venomous_logic_callback(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
	var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
	if target == null or target.is_queued_for_deletion(): return
	var damage := int(float(target.stats.poison_stacks) * _poison_stats.poison_venomous_darts_multiplier)
	_owner.direct_attack(target, damage, Utils.DamageType.PHYSICAL)
#endregion

#region TIDE OF CORRUPTION
func _on_tide_of_corruption_timer_timeout() -> void:
	var targets: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
	if targets.is_empty(): return
	var target_number: int = targets.size()
	var poison_stacks: int = int(_poison_stats.poison_tide_of_corruption_multiplier * float(target_number))
	for target in targets:
		_owner.inflict_condition_stacks(target, poison_stacks, Utils.StackType.POISON)
#endregion

#region CONTAGION
func _register_contagion() -> void:
	var fighting_event := FightingEvent.new()
	fighting_event.id = "Contagion"
	fighting_event.tags = [FightingEvent.TagType.CARD]
	fighting_event.enabled = true
	fighting_event.is_one_time_effect = false
	fighting_event.on_entity_died_callback = _on_enemy_died_contagion
	#fighting_area.fighting_event_registry.register_event(fighting_event)


func _on_enemy_died_contagion(cb_vars: Dictionary) -> void:
	var entities: Array[Entity] = cb_vars[FightingEvent.VarType.ENTITIES]
	var victim: Entity = cb_vars[FightingEvent.VarType.VICTIM]
	if victim == null: return
	if victim.team_id == _owner.team_id: return
	
	var poison_stacks := victim.stats.poison_stacks
	if poison_stacks <= 0: return
	
	var radius: float = _poison_stats.poison_contagion_radius
	var targets := []
	for entity in entities:
		if entity.team_id == victim.team_id and !entity.is_dead and entity != victim:
			if entity.global_transform.origin.distance_to(victim.global_transform.origin) <= radius:
				targets.append(entity)
	
	var spread := int(poison_stacks * 0.5)
	for target in targets:
		_owner.inflict_condition_stacks(target, spread, Utils.StackType.POISON)
#endregion








 
