class_name FireManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _fire_stats: FamilyFireStats # Ref to the owner fire stats

var _meteor_modifiers: Array

# [TITANS PROTECTION]
var _titans_protection_accumulated_hp: float = 0.0

# ============================== Local nodes ==============================

const _IGNITE_DECAY_PERCENT: float = 10.0
const _IGNITE_PERCENT_PER_STACK: float = 0.05

# ============================== Node base functions ==============================

func _ready() -> void:
	_fire_stats = _owner.families_stats.fire

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	_on_battle_start()
	_add_stat_modifiers()
	_add_action_modifiers()
	_add_stack_modifiers()
	_add_meteor_modifiers()
	_titans_protection_accumulated_hp = 0.0


func stop() -> void:
	_clear_meteor_modifiers()
	_clear_stack_modifiers()
	for spell in _optional_spells:
		spell.queue_free()
	_clear_optional_timers()


# ============================== Private functions ==============================
#region on battle start
func _on_battle_start() -> void:
	# [nuke]
	if _fire_stats.nuke_activated:
		var targets: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
		for target: Entity in targets:
			_owner.inflict_condition_stacks(target, _fire_stats.nuke_ignite, Utils.StackType.IGNITE, "Nuke")
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

#region meteor modifiers
func _add_meteor_modifiers() -> void:
	# [END OF THE WORLD]
	if _fire_stats.end_of_the_world_activated:
		_meteor_modifiers.append(_on_end_of_the_world_meteor_hit)
		
# [KUIPER BELT]
	if _fire_stats.kuiper_belt_activated:
		_meteor_modifiers.append(_on_kuiper_belt_meteor_hit)
	
	# [TITANS PROTECTION]
	if _fire_stats.titans_protection_activated:
		_meteor_modifiers.append(_on_titans_protection_meteor_hit)
		
		# [CONSUMING THE STAR]
	if _fire_stats.consuming_the_star_activated:
		_meteor_modifiers.append(_on_consuming_the_star_meteor_hit)
		
	# [SCORPIUS]
	if _fire_stats.scorpius_activated:
		_meteor_modifiers.append(_on_scorpius_meteor_hit)

	# [APOCALYPSE]
	if _fire_stats.fire_apocalypse_activated:
		_meteor_modifiers.append(_on_apocalypse_meteor_hit)
		
	# [COSMO'POLITAN]
	if _fire_stats.fire_cosmopolitan_activated:
		_meteor_modifiers.append(_on_cosmopolitan_meteor_hit)

func _clear_meteor_modifiers() -> void:
	_meteor_modifiers.clear()
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
		_owner.stat_modifiers_registry.register_modifier(mod)
		
	# [ORBITAL STATION]
	if _fire_stats.orbital_station_activated:
		var mod := StatModifier.new()
		mod.id = "Orbital Station"
		mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		mod.action_type = Utils.ActionType.STACK_IGNITE # (Vérifie que STACK_IGNITE existe)
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _fire_stats.orbital_station_crit_chance
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stat_modifiers_registry.register_modifier(mod)

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
		_owner.action_modifiers_registry.register_modifier(action_modifier)

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
		_owner.action_modifiers_registry.register_modifier(stack_modifier)


func _clear_stack_modifiers() -> void:
	# [FAMILY PASSIVE]
	if true:
		var stack_modifier := ActionModifier.new()
		stack_modifier.action_type = ActionModifier.ActionType.INFLICT_CONDITION
		stack_modifier.id = "Celestial Passive"
		stack_modifier.tags = [ActionModifier.TagType.CARD]
		stack_modifier.after_action_logic_callback = _on_inflict_condition_ignite
		stack_modifier.is_one_time_effect = false
		_owner.action_modifiers_registry.unregister_modifier(stack_modifier)
#endregion

#region others cards
func _lanch_optional_spells() -> void:
	pass
#endregion

# ============================== Callbacks functions ==============================

#region ===== EXPANSE UNIVERSE =====
# [EXPANSE UNIVERSE]
func _on_expanse_universe_timer_timeout() -> void:
	if _owner == null or not is_instance_valid(_owner):
		return
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_HP_PERCENT_ENEMY)
	if target == null or not is_instance_valid(target):
		return
	var stacks: int = int(_fire_stats.expanse_universe_ignite_stacks)
	if stacks > 0:
		_owner.inflict_condition_stacks(target, stacks, Utils.StackType.IGNITE, "Expanse Universe")
#endregion

#region ===== DARK FOREST =====
# [DARK FOREST]
func _on_dodge_dark_forest(_cb_vars: Dictionary) -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		_owner.inflict_condition_stacks(target, _fire_stats.dark_forest_ignite_stacks, Utils.StackType.IGNITE, "Dark Forest")
		
#endregion

#region ===== SCORPIUS =====
# [SCORPIUS]
func _on_scorpius_meteor_hit(cb_vars: Dictionary) -> void:
	var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
	if entities_inside.is_empty(): return
	var poison_amount: float = _fire_stats.scorpius_poison_stacks
	for entity: Entity in entities_inside:
		if entity != null and is_instance_valid(entity) and entity.team != _owner.team:
			_owner.inflict_condition_stacks(entity, int(poison_amount), Utils.StackType.POISON, "Scorpius")
#endregion

#region ===== CONSUMING THE STAR =====
# [CONSUMING THE STAR]
func _on_consuming_the_star_meteor_hit(cb_vars: Dictionary) -> void:
	var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
	if entities_inside.is_empty(): return
	var burn_amount: float = _fire_stats.consuming_the_star_mana_burn
	for entity: Entity in entities_inside:
		if entity != null and is_instance_valid(entity) and entity.team != _owner.team:
			if entity.stats.mana > 0:
				entity.stats.mana = max(0.0, entity.stats.mana - burn_amount)
#endregion

#region =====TITANS PROTECTION =====
# [TITANS PROTECTION]
func _on_titans_protection_meteor_hit(_cb_vars: Dictionary) -> void:
	if _owner == null or not is_instance_valid(_owner): return
	var amount: float = _fire_stats.titans_protection_hp_amount
	if amount > 0:
		_titans_protection_accumulated_hp += amount
		var mod := StatModifier.new()
		mod.id = "Fire Titan Protection"
		mod.stat_type = EntityStats.StatType.HEALTH_MAX
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _titans_protection_accumulated_hp
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stat_modifiers_registry.update_modifier(mod)
#endregion

#region ========== KUIPER BELT ==========
# [KUIPER BELT]
func _on_kuiper_belt_meteor_hit(_cb_vars: Dictionary) -> void:
	if _owner == null or not is_instance_valid(_owner): return
	var amount: int = int(_fire_stats.kuiper_belt_shield_amount)
	if amount > 0:
		_owner.inflict_condition_stacks(_owner, amount, Utils.StackType.SHIELD, "Kuiper Belt")
#endregion

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
	var ignite_stacks: float = target.conditions.ignite_stacks
	var dmg_mult: float = _fire_stats.cosmic_bolt_damage_per_stack
	var damage: float = ignite_stacks * dmg_mult
	
	if damage > 0:
		_owner.direct_attack(target, damage, Utils.DamageType.MAGICAL, "Cosmic Bolt")
	
	# --- 2. Rebond ---
	var chance_mult: float = _fire_stats.cosmic_bolt_bounce_chance_per_stack
	var bounce_chance: float = float(ignite_stacks) * chance_mult
	
	if Utils.is_randomize_modifier_active(bounce_chance):
		var new_target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		
		if new_target != null:
			_shoot_cosmic_bolt(new_target)
#endregion

#region ========== END OF THE WORLD ==========
func _on_end_of_the_world_meteor_hit(cb_vars: Dictionary) -> void:
	var _entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
	for entity: Entity in _entities_inside:
		var hp = entity.stats.health
		var ignite_stacks = entity.conditions.ignite_stacks
		var stack_multiplier = _fire_stats.end_of_the_world_stack_multiplier
		if entity.team != _owner.team and hp <= ignite_stacks * stack_multiplier:
			entity.stats.health = 0
#endregion

#region ========== APOCALYPSE ==========
# [APOCALYPSE]
func _on_apocalypse_meteor_hit(cb_vars: Dictionary) -> void:
	var _entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
	var ratio: float = _fire_stats.fire_apocalypse_damage_ratio
	
	for entity: Entity in _entities_inside:
		if entity == null or not is_instance_valid(entity) or entity.is_dead: continue
		if entity.team == _owner.team: continue
		
		var ignite_stacks = entity.conditions.ignite_stacks
		if ignite_stacks > 0:
			var bonus_damage = ignite_stacks * ratio
			_owner.direct_attack(entity, bonus_damage, Utils.DamageType.MAGICAL, "Apocalypse")
#endregion

		if ignite_stacks > 0:
			var bonus_damage = ignite_stacks * ratio
			_owner.direct_attack(entity, bonus_damage, Utils.DamageType.MAGICAL, "Apocalypse")
#endregion

#region ========== COSMO'POLITAN ==========
# [COSMO'POLITAN]
func _on_cosmopolitan_meteor_hit(cb_vars: Dictionary) -> void:
	var _entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
	var damage_percent: float = cb_vars.get(Meteor.VarType.DAMAGE_PERCENT, 0.0)
	
	# Filter actual targets (enemies)
	var targets: Array[Entity] = []
	for entity: Entity in _entities_inside:
		if entity != null and is_instance_valid(entity) and not entity.is_dead and entity.team != _owner.team:
			targets.append(entity)
			
	if targets.size() == 1:
		var target = targets[0]
		var bonus_ratio: float = _fire_stats.fire_cosmopolitan_bonus_damage_ratio
		var extra_damage_percent: float = damage_percent * bonus_ratio
		
		_owner.direct_attack_percent(target, extra_damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP, "Cosmo'Politan")
#endregion

# ============================== PASSIF ==============================

 #region ==========  PASSIVE ==========
# [PASSIVE]
func _on_inflict_condition_ignite(cb_vars: Dictionary) -> void:
	if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
	var stack_type: Utils.StackType = cb_vars[ActionModifier.VarType.STACK_TYPE]
	var stack_value: Utils.StackType = cb_vars.get(ActionModifier.VarType.STACK_VALUE, 0)
	var target: Entity = cb_vars.get(ActionModifier.VarType.TARGET, null)
	if target == null: return
	if stack_type != Utils.StackType.IGNITE: return
	for i in stack_value:
		if Utils.is_randomize_modifier_active(2):
			_owner.cast_spell(target, Spell.Type.METEOR, {
					Spell.MeteorModifier.DAMAGE_PERCENT: 5.0,
					Spell.MeteorModifier.RADIUS: 3.0,
					Spell.MeteorModifier.ON_HIT_CALLBACKS: _meteor_modifiers
					})
#endregion
