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
	_add_stack_modifiers()
	_poison_tick_timer.start()


func stop() -> void:
	for spell in _optional_spells:
		spell.queue_free()
	_poison_tick_timer.stop()
	_clear_stat_modifiers()
	_clear_attack_modifiers()
	_clear_optional_timers()

# ============================== Private functions ==============================

func _add_stack_modifiers() -> void:
	# [HOT POT]
	if _poison_stats.poison_hot_pot_activated:
		var stack_modifier := ActionModifier.new()
		stack_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		stack_modifier.id = "Hot Pot"
		stack_modifier.tags = [ActionModifier.TagType.CARD]
		stack_modifier.after_action_logic_callback = _on_inflict_condition_hot_pot
		stack_modifier.is_one_time_effect = false
		_owner.action_modifiers_manager.register_modifier(stack_modifier)
	
	# [ROTTING MILK]
	if _poison_stats.poison_rotting_milk_activated:
		var stack_modifier := ActionModifier.new()
		stack_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		stack_modifier.id = "Rotting Milk"
		stack_modifier.tags = [ActionModifier.TagType.CARD]
		stack_modifier.after_action_logic_callback = _on_inflict_condition_rotting_milk
		stack_modifier.is_one_time_effect = false
		_owner.action_modifiers_manager.register_modifier(stack_modifier)
	
	# [CORROSION ACTIVATED]
	if _poison_stats.poison_corrosion_activated:
		var stack_modifier := ActionModifier.new()
		stack_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		stack_modifier.id = "Corrosion"
		stack_modifier.tags = [ActionModifier.TagType.CARD]
		stack_modifier.after_action_logic_callback = _on_inflict_condition_corrosion
		stack_modifier.is_one_time_effect = false
		_owner.action_modifiers_manager.register_modifier(stack_modifier)

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
		mod.stat_type = EntityStats.StatType.RESISTANCE
		mod.action_type = Utils.ActionType.DAMAGE_POISON
		mod.id = "Antidote"
		_owner.stats_manager.register_modifier(mod)

func _clear_stat_modifiers() -> void:
	if _poison_stats.poison_antidote_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.RESISTANCE
		mod.action_type = Utils.ActionType.DAMAGE_POISON
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
	
	# [SHROOMS]
	if _poison_stats.poison_shrooms_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self , _poison_stats.poison_shrooms_period, _on_shrooms_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()


func _lanch_optional_spells() -> void:
	# [CONTAGION]
	if _poison_stats.poison_contagion_activated:
		var spell_modifier: Dictionary = {
			Spell.ContagionModifier.RADIUS: _poison_stats.poison_contagion_radius,
			Spell.ContagionModifier.SPREAD_PERCENT: _poison_stats.poison_contagion_percent
		}
		_owner.cast_spell(_owner, Spell.Type.CONTAGION, spell_modifier)
	
	# [SNAKE BARREL]
	if _poison_stats.poison_snake_barrel_activated:
		_summon_snake_barrel()
	
	# [DEATH FOG]
	if _poison_stats.poison_death_smoke_activated:
		var spell_modifier: Dictionary = {
			Spell.DeathFogModifier.GROW_SPEED: 0.2,
			Spell.DeathFogModifier.TICK_PERIOD: _poison_stats.poison_death_smoke_period,
			Spell.DeathFogModifier.DAMAGE_MULTIPLIER: _poison_stats.poison_death_smoke_multiplier,
		}
		_owner.cast_spell(_owner, Spell.Type.DEATH_FOG, spell_modifier)

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

#region SHROOM
func _on_shrooms_timer_timeout() -> void:
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var spell_modifier: Dictionary = {
		Spell.ShroomModifier.RADIUS: _poison_stats.poison_shrooms_radius,
		Spell.ShroomModifier.DAMAGE: _poison_stats.poison_shrooms_damage,
		Spell.ShroomModifier.LIFE_TIME: _poison_stats.poison_shrooms_life_time
	}
	_owner.cast_spell(target, Spell.Type.SHROOM, spell_modifier)
#endregion

#region SNAKE BARREL
const FIGHTING_AREA_SIZE := Vector2(20, 10)
func _on_snake_barrel_timer_timeout() -> void:
	_summon_snake_barrel()

func _summon_snake_barrel() -> void:
	var center := Vector3(0, 0, 0)
	var half_w := FIGHTING_AREA_SIZE.x * 0.1
	var half_d := FIGHTING_AREA_SIZE.y * 0.5

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var dx := rng.randf_range(-half_w, half_w)
	var dz := rng.randf_range(-half_d, half_d)

	var summon_modifier :Dictionary = {
		Entity.SnakeBarrelModifier.SNAKE_NUMBER: _poison_stats.poison_snake_barrel_snake_number,
		Entity.SnakeBarrelModifier.SNAKE_POISON_STACKS: _poison_stats.poison_snake_barrel_snake_poison_stacks,
		Entity.SnakeBarrelModifier.MAX_HEALTH: _poison_stats.poison_snake_barrel_health
	}
	_owner.summon_entity(Entity.EntityType.SNAKE_BARREL, _owner.to_global(Vector3(center.x + dx, center.y, center.z + dz)), summon_modifier)
#endregion
 
# ============================== Callbacks functions ==============================

func _on_inflict_condition_hot_pot(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
	if not cb_vars.has(ActionModifier.VarType.TARGET): return
	var stack_type: Utils.StackType = cb_vars[ActionModifier.VarType.STACK_TYPE]
	var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
	if stack_type != Utils.StackType.POISON: return
	if Utils.is_randomize_modifier_active(_poison_stats.poison_hot_pot_chance):
		_owner.inflict_condition_stacks(target, _poison_stats.poison_hot_pot_ignite_stacks, Utils.StackType.IGNITE)


func _on_inflict_condition_rotting_milk(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
	var stack_type: Utils.StackType = cb_vars[ActionModifier.VarType.STACK_TYPE]
	if stack_type != Utils.StackType.POISON: return
	if Utils.is_randomize_modifier_active(_poison_stats.poison_rotting_milk_chance):
		_owner.inflict_condition_stacks(_owner, _poison_stats.poison_rotting_milk_regen_stacks, Utils.StackType.REGEN)


func _on_inflict_condition_corrosion(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
	if not cb_vars.has(ActionModifier.VarType.TARGET): return
	var stack_type: Utils.StackType = cb_vars[ActionModifier.VarType.STACK_TYPE]
	var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
	if stack_type != Utils.StackType.POISON: return
	if Utils.rng.randi() % 2 == 0:
		target.stats.armor_stacks -= _poison_stats.poison_corrosion_buff_stacks
	else:
		target.stats.regen_stacks -= _poison_stats.poison_corrosion_buff_stacks
