class_name FireManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _fire_stats: FamilyFireStats # Ref to the owner fire stats

# ============================== Local nodes ==============================

@onready var _ignite_timer: Timer = %IgniteTimer

const _IGNITE_DECAY_PERCENT: float = 10.0
const _IGNITE_PERCENT_PER_STACK: float = 0.05

# ============================== Node base functions ==============================

func _ready() -> void:
	_fire_stats = _owner.families_stats.fire

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	_ignite_timer.start()
	_on_battle_start()
	_add_stat_modifiers()
	_add_action_modifiers()
	_add_stack_modifiers()


func stop() -> void:
	_add_stack_modifiers()
	_clear_stat_modifiers()
	_remove_action_modifiers()
	for spell in _optional_spells:
		spell.queue_free()
	_ignite_timer.stop()
	_clear_optional_timers()


# ============================== Private functions ==============================
#region on battle start

func _on_battle_start() -> void:
	# [nuke]
	if _fire_stats.nuke_activated:
		var targets: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
		for target: Entity in targets:
			_owner.inflict_condition_stacks(target,_fire_stats.nuke_ignite,Utils.StackType.IGNITE)
		


#endregion

#region optional timer

func _create_optional_timers() -> void:
	
	# [EXPANSE UNIVERSE]
	if _fire_stats.expanse_universe_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.expanse_universe_period, _on_expanse_universe_timer_timeout, true))
	
	# [COSMIC BOLT]
	if _fire_stats.cosmic_bolt_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.cosmic_bolt_period, _on_cosmic_bolt_timer_timeout, true))

func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()

#endregion

#region aa modifier
#endregion

#region stats modifier

func _add_stat_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _fire_stats.dark_forest_increase_dodge
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Dark Forest"
		_owner.stats_manager.register_modifier(mod)
		
func _clear_stat_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.DODGE
		mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
		mod.id = "Dark Forest"
		_owner.stats_manager.unregister_modifier(mod)
		
#endregion

#region actions modifier

func _add_action_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Dark Forest"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_dark_forest
		_owner.action_modifiers_manager.register_modifier(action_modifier)

func _remove_action_modifiers() -> void:
	# [DARK FOREST]
	if _fire_stats.dark_forest_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Dark Forest"
		action_modifier.after_action_logic_callback = _on_dodge_dark_forest
		_owner.action_modifiers_manager.unregister_modifier(action_modifier)
		
#endregion

#region on inflict stacks modifier

func _add_stack_modifiers() -> void:
	
	# [FAMILY FIRE PASSIVE]
	if true:
		var stack_modifier := ActionModifier.new()
		stack_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		stack_modifier.id = "Celestial Passive"
		stack_modifier.tags = [ActionModifier.TagType.CARD]
		stack_modifier.after_action_logic_callback = _on_inflict_condition_ignite
		stack_modifier.is_one_time_effect = false
		_owner.action_modifiers_manager.register_modifier(stack_modifier)
		
func _clear_stack_modifiers() -> void:
	
	# [FAMILY PASSIVE]
	if true:
		var stack_modifier := ActionModifier.new()
		stack_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		stack_modifier.id = "Celestial Passive"
		stack_modifier.tags = [ActionModifier.TagType.CARD]
		stack_modifier.after_action_logic_callback = _on_inflict_condition_ignite
		stack_modifier.is_one_time_effect = false
		_owner.action_modifiers_manager.unregister_modifier(stack_modifier)
		
#endregion

#region others cards

func _lanch_optional_spells() -> void:
	pass
	
#endregion


	
# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	pass

# [EXPANSE UNIVERSE]
func _on_expanse_universe_timer_timeout() -> void:
	if _owner == null or not is_instance_valid(_owner):
		return
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_HP_PERCENT_ENEMY)
	if target == null or not is_instance_valid(target):
		return
	var stacks: int = int(_fire_stats.expanse_universe_ignite_stacks)
	if stacks > 0:
		_owner.inflict_condition_stacks(target, stacks, Utils.StackType.IGNITE)

#[DECAY]
func _on_ignite_timer_timeout() -> void:
	if _owner.stats.ignite_stacks > 0:
		var percent: float = _IGNITE_PERCENT_PER_STACK * _owner.stats.ignite_stacks
		_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.DamageType.MAGICAL)
	
	var decay: int = (_owner.stats.ignite_stacks * _IGNITE_DECAY_PERCENT / 100.0) as int
	decay = clampi(decay, 1, decay)
	_owner.stats.ignite_stacks -= decay


# [DARK FOREST]
func _on_dodge_dark_forest(_cb_vars: Dictionary) -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		_owner.inflict_condition_stacks(target, _fire_stats.dark_forest_ignite_stacks, Utils.StackType.IGNITE)


#region ========== COSMIC BOLT ==========

# [COSMIC BOLT] - Déclenchement Timer
func _on_cosmic_bolt_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_HP_ENEMY)
	if target == null: return
	
	_shoot_cosmic_bolt(target)

# [COSMIC BOLT] - Fonction de tir
func _shoot_cosmic_bolt(target: Entity) -> void:
	if target == null or not is_instance_valid(target): return

	var proj_stats := ProjectileStats.new()
	
	proj_stats.is_bouncing = false 

	proj_stats.on_hit_logic_callbacks.append(_on_hit_cosmic_bolt)
	

	_owner.projectile_attack(target, Projectile.ProjectileType.COSMIC_BOLT, _owner._turret._projectile_spawn_point, proj_stats)


# [COSMIC BOLT] - Logique à l'impact
func _on_hit_cosmic_bolt(cb_vars: Dictionary) -> void:
	if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
	var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
	if target == null or not is_instance_valid(target) or target.is_queued_for_deletion(): return
	
	# --- 1. Dégâts ---
	var ignite_stacks: int = target.stats.ignite_stacks

	
	var dmg_mult: float = _fire_stats.cosmic_bolt_damage_per_stack
	var damage: int = int(float(ignite_stacks) * dmg_mult)
	
	if damage > 0:
		_owner.direct_attack(target, damage, Utils.DamageType.MAGICAL)
	
	# --- 2. Rebond ---
	var chance_mult: float = _fire_stats.cosmic_bolt_bounce_chance_per_stack
	var bounce_chance: float = float(ignite_stacks) * chance_mult
	
	if Utils.is_randomize_modifier_active(bounce_chance):
		# Trouver une nouvelle cible différente
		var new_target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		
		if new_target != null:
			# On tire un nouveau projectile depuis la position de la cible actuelle
			# (Ou depuis le lanceur, selon ton choix visuel. 
			# Si tu veux que ça parte de la cible touchée, il faudrait modifier projectile_attack pour accepter une pos de départ custom)
			
			# Pour l'instant, on tire depuis le lanceur (simple):
			_shoot_cosmic_bolt(new_target)
#endregion
# ============================== PASSIF ==============================
 
# [PASSIVE]
func _on_inflict_condition_ignite(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
	if not cb_vars.has(ActionModifier.VarType.STACK_VALUE): return
	if not cb_vars.has(ActionModifier.VarType.TARGET): return
	var stack_type: Utils.StackType = cb_vars[ActionModifier.VarType.STACK_TYPE]
	var stack_value: Utils.StackType = cb_vars[ActionModifier.VarType.STACK_VALUE]
	var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
	if target == null: return
	if stack_type != Utils.StackType.IGNITE: return
	for i in stack_value:
		if Utils.is_randomize_modifier_active(2):
			_owner.cast_spell(target,Spell.Type.METEOR,{
					Spell.MeteorModifier.IGNITE_STACKS: 0,
					Spell.MeteorModifier.DAMAGE_PER_STACK: 0
					})
