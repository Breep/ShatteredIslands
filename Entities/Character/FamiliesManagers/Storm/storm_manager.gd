class_name StormManager
extends FamilyManager

# ============================== Signals ==============================

signal rank_changed(new_rank: Rank)

# ============================== Enums ==============================

enum Rank {
	D,
	C,
	B,
	A,
	S
}

# ============================== Constants ==============================

const CRIT_POINT_DEFAULT: float = 1.0
const CRIT_POINT_MULT: float = 0.5
const RANK_POINT_TRESHOLDS: Dictionary[Rank, float] = {
	Rank.D: 0.0,
	Rank.C: 5.0,
	Rank.B: 15.0,
	Rank.A: 30.0,
	Rank.S: 50.0
}

const RANK_S_DURATION: float = 1.6
const RANK_S_LIGHTNING_COOLDOWN: float = 0.4

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GLOBAL_CRIT_MULTIPLIER_BOOSTS: Array[float] = [25.0, 50.0, 75.0, 100.0]
const GLOBAL_CRIT_CHANCE_BOOSTS: Array[float] = [2.5, 2.5, 5.0, 7.5, 10.0]
const BASE_LIGHTNING_DAMAGE_PERCENT: Array[float] = [70.0, 90.0, 110.0, 130.0, 150.0]

# --- MULTIPLICATEUR DYNAMIQUE (Dépend du Rang D-S) ---
const RANK_VALUE_MULTIPLIERS: Dictionary[Rank, float] = {
	Rank.D: 0.7,
	Rank.C: 0.85,
	Rank.B: 1.0,
	Rank.A: 1.2,
	Rank.S: 1.5
}

# ============================== Private variables ==============================

var _storm_stats: FamilyStormStats

var __current_rank: Rank = Rank.D
var _current_rank: Rank:
	get: return __current_rank
	set(value):
		if __current_rank == value: return
		__current_rank = value
		rank_changed.emit(value)
		_on_current_rank_changed()
		
var _current_point: float = 0.0
var _storm_breaker_memory: Dictionary = {}
var _lightning_spam_timer: Timer

# [LIGHTNING FOOTWORK]
var _lightning_footwork_current_bonus: float = 0.0

# [EYE OF THE CYCLONE]
var _eye_of_the_cyclone_accumulated_bonus: float = 0.0

# [THUNDER BERSERKER]

# [THUNDER BERSERKER]
var _thunder_berserker_penalty_active: bool = false
var _thunder_berserker_accumulated_penalty: float = 0.0

# ============================== Local Nodes ==============================

@onready var _rank_s_duration_timer: Timer = %RankSTimer

# ============================== Public functions ==============================

func _ready() -> void:
	_storm_stats = _owner.families_stats.storm
	_owner.critical_action_done.connect(_on_owner_critical_action_done)
	

func start() -> void:
	_create_optional_timers()
	for timer in _optional_timers:
		timer.start()
	_add_stat_modifiers()
	_add_action_modifiers()
	_storm_breaker_memory.clear()
	_current_point = 0
	_current_rank = Rank.D
	# [THUNDER BERSERKER]
	_thunder_berserker_penalty_active = false
	_thunder_berserker_accumulated_penalty = 0.0
	# [EYE OF THE CYCLONE]
	_eye_of_the_cyclone_accumulated_bonus = 0.0

# ============================== Private functions ==============================

func stop() -> void:
	_stop_lightning_rod()

	if _lightning_spam_timer:
		_lightning_spam_timer.stop()
	_clear_optional_timers()

# ============================== Private functions ==============================

#region optional timer
func _create_optional_timers() -> void:
	# [RANK S SPAM]
	_lightning_spam_timer = Timer.new()
	_lightning_spam_timer.wait_time = RANK_S_LIGHTNING_COOLDOWN
	_lightning_spam_timer.one_shot = false
	_lightning_spam_timer.timeout.connect(_on_lightning_spam_timer_timeout)
	add_child(_lightning_spam_timer)
	
	# [THUNDER BERSERKER]
	if _storm_stats.thunder_berserker_activated:
		var tb_timer := Timer.new()
		tb_timer.wait_time = _storm_stats.thunder_berserker_delay
		tb_timer.one_shot = true
		tb_timer.timeout.connect(_on_thunder_berserker_timeout)
		add_child(tb_timer)
		_optional_timers.append(tb_timer)

func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
#endregion

#region stats modifier

func _add_stat_modifiers() -> void:
	# [THUNDER BERSERKER] - Boost Initial
	if _storm_stats.thunder_berserker_activated:
		var mod := StatModifier.new()
		mod.id = "Thunder Berserker Boost"
		mod.stat_type = EntityStats.StatType.CRIT_MULT
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _storm_stats.thunder_berserker_start_boost
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(mod)
		
	# [FARADAY]
	if _storm_stats.faraday_activated:
		for action_type in Utils.get_all_actions():
			var mod := StatModifier.new()
			mod.stat_type = EntityStats.StatType.CRIT_CHANCE
			mod.action_type = action_type
			mod.calc_type = StatModifier.CalcType.ADD
			mod.id = "Faraday"
			mod.tags = [StatModifier.TagType.CARD]
			mod.value = _storm_stats.faraday_crit_chance_boost
			_owner.stats_manager.register_modifier(mod)
			
	# [VIOLENT OVERLOAD]
	if _storm_stats.violent_overload_activated:
		for action_type in Utils.get_all_actions():
			var mod := StatModifier.new()
			mod.stat_type = EntityStats.StatType.CRIT_MULT
			mod.action_type = action_type
			mod.calc_type = StatModifier.CalcType.ADD
			mod.id = "Violent Overload"
			mod.tags = [StatModifier.TagType.CARD]
			mod.value = _storm_stats.violent_overload_crit_mult_boost
			_owner.stats_manager.register_modifier(mod)

	# [LIGHTNING FOOTWORK]
	if _storm_stats.lightning_footwork_activated:
		var mod := StatModifier.new()
		mod.id = "Lightning Footwork"
		mod.stat_type = EntityStats.StatType.DODGE
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = _lightning_footwork_current_bonus
		mod.tags = [StatModifier.TagType.CARD]
		_owner.stats_manager.register_modifier(mod)
		
	# [LIGHTNING ROD]
	if _storm_stats.lightning_rod_activated:
		if not _owner.stats.health_changed.is_connected(_on_lightning_rod_health_changed):
			_owner.stats.health_changed.connect(_on_lightning_rod_health_changed)
		_on_lightning_rod_health_changed(_owner.stats.health) # Initial check
		
#endregion

#region action modifier

func _add_action_modifiers() -> void:
	# [LIGHTNING FOOTWORK]
	if _storm_stats.lightning_footwork_activated:
		var action_modifier := ActionModifier.new()
		action_modifier.action_type = ActionModifier.ActionType.DODGE
		action_modifier.id = "Lightning Footwork"
		action_modifier.is_one_time_effect = false
		action_modifier.after_action_logic_callback = _on_dodge_lightning_footwork
		_owner.action_modifiers_manager.register_modifier(action_modifier)

#endregion

#region actions logic

func _get_crit_point(default_damage: float, real_damage: float) -> float:
	if real_damage < 0: return 0
	if default_damage < 1.0: return CRIT_POINT_DEFAULT
	return CRIT_POINT_DEFAULT + (real_damage / default_damage) * CRIT_POINT_MULT

func _call_the_lightning() -> void:
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	#TODO adapté avec le niveau de famille
	var current_lvl: int = 1
	var base_percent: float = BASE_LIGHTNING_DAMAGE_PERCENT[current_lvl]
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	var final_percent: float = base_percent * rank_mult
	var damage: float = _owner.stats.attack_damage * final_percent / 100.0
	_owner.cast_spell(target, Spell.Type.LIGHTNING, {Spell.LightningModifier.DAMAGE: damage})
	
	# [ELECTROCUTE]
	if _storm_stats.electrocute_activated:
		if Utils.is_randomize_modifier_active(_storm_stats.electrocute_chance):
			_owner.inflict_condition_stacks(target, _storm_stats.electrocute_necrosis_amount, Utils.StackType.NECROSIS, "Electrocute")

# [STORM BREAKER]
func _apply_storm_breaker_effect() -> void:
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null or not is_instance_valid(target): return
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	var base_percent: float = _storm_stats.storm_breaker_base_reduction_percent
	var added_percent: float = base_percent * rank_mult
	if added_percent <= 0: return
	var current_total: float = 0.0
	if _storm_breaker_memory.has(target):
		current_total = _storm_breaker_memory[target]
	var new_total: float = current_total + added_percent
	_storm_breaker_memory[target] = new_total
	var mod := StatModifier.new()
	mod.id = "Storm Breaker"
	mod.stat_type = EntityStats.StatType.VULNERABILITY
	mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = new_total
	mod.tags = [StatModifier.TagType.CARD]
	target.stats_manager.update_modifier(mod)

# [LIGHTNING ROD]
func _stop_lightning_rod() -> void:
	if _owner.stats.health_changed.is_connected(_on_lightning_rod_health_changed):
		_owner.stats.health_changed.disconnect(_on_lightning_rod_health_changed)
	_apply_lightning_rod_modifier(false)

func _apply_storm_battery_effect() -> void:
	if _owner == null or not is_instance_valid(_owner): return
	
	# Multiplicateur de Rang s'applique ici
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	
	var base_mana: float = _storm_stats.storm_battery_mana_gain
	var final_mana: float = base_mana * rank_mult
	
	if final_mana > 0:
		_owner.stats.mana += final_mana

# [THUNDER BERSERKER]
func _apply_thunder_berserker_penalty() -> void:
	_thunder_berserker_accumulated_penalty += _storm_stats.thunder_berserker_penalty_per_rank
	var mod := StatModifier.new()
	mod.id = "Thunder Berserker Penalty"
	mod.stat_type = EntityStats.StatType.CRIT_MULT
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = - (_thunder_berserker_accumulated_penalty)
	mod.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.update_modifier(mod)

func _update_lightning_footwork_modifier() -> void:
	var mod := StatModifier.new()
	mod.id = "Lightning Footwork"
	mod.stat_type = EntityStats.StatType.DODGE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _lightning_footwork_current_bonus
	mod.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.update_modifier(mod)

# [DYNAMO]
func _apply_dynamo_effect() -> void:
	if _owner == null or not is_instance_valid(_owner): return
	
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	
	# Regen
	var base_regen: float = _storm_stats.dynamo_regen
	var final_regen: float = base_regen * rank_mult
	if final_regen > 0:
		_owner.inflict_condition_stacks(_owner, final_regen, Utils.StackType.REGEN, "Dynamo")
		
	# Shield
	var base_shield: float = _storm_stats.dynamo_shield
	var final_shield: float = base_shield * rank_mult
	if final_shield > 0:
		_owner.inflict_condition_stacks(_owner, final_shield, Utils.StackType.ARMOR, "Dynamo")
		
# [EYE OF THE CYCLONE]
func _apply_eye_of_the_cyclone_effect() -> void:
	var max_hp_bonus: float = _owner.base_stats.health_max * (_storm_stats.eye_of_the_cyclone_max_hp_percent / 100.0)
	_eye_of_the_cyclone_accumulated_bonus += max_hp_bonus
	
	var mod := StatModifier.new()
	mod.id = "Eye of the Cyclone"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _eye_of_the_cyclone_accumulated_bonus
	mod.tags = [StatModifier.TagType.CARD]
	_owner.stats_manager.update_modifier(mod)
	
	_owner.heal(_owner, max_hp_bonus, "Eye of the Cyclone")

# [LIGHTNING ROD]
func _on_lightning_rod_health_changed(new_health: float) -> void:
	if not _storm_stats.lightning_rod_activated: return
	if _owner.stats.health_max == 0: return
	
	var percent: float = (new_health / _owner.stats.health_max) * 100.0
	
	if percent > _storm_stats.lightning_rod_hp_threshold_percent:
		_apply_lightning_rod_modifier(true)
	else:
		_apply_lightning_rod_modifier(false)

func _apply_lightning_rod_modifier(enabled: bool) -> void:
	var mod_id: String = "Lightning Rod"
	if enabled:
		for action_type in Utils.get_all_actions():
			var mod := StatModifier.new()
			mod.id = mod_id + str(action_type)
			mod.stat_type = EntityStats.StatType.CRIT_RESISTANCE
			mod.action_type = action_type
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = _storm_stats.lightning_rod_resistance_amount
			mod.tags = [StatModifier.TagType.CARD]
			_owner.stats_manager.register_modifier(mod)
	else:
		for action_type in Utils.get_all_actions():
			_owner.stats_manager.remove_modifier(mod_id + str(action_type))

#endregion

# [CHAIN LIGHTNING]
func _apply_chain_lightning_effect(hit_victim: Entity, original_damage: float) -> void:
	if hit_victim == null or not is_instance_valid(hit_victim): return
	
	var enemies: Array[Entity] = _owner.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
	if enemies.is_empty(): return
	
	var furthest_enemy: Entity = null
	var max_dist_sq: float = -1.0
	var victim_pos = hit_victim.global_position # On calcule depuis la victime !
	
	# 1. Trouver le plus loin DEPUIS LA VICTIME
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy != hit_victim and not enemy.is_dead:
			var dist_sq = victim_pos.distance_squared_to(enemy.global_position)
			if dist_sq > max_dist_sq:
				max_dist_sq = dist_sq
				furthest_enemy = enemy
	
	if furthest_enemy == null:
		return
	var distance: float = sqrt(max_dist_sq)
	distance = min(distance, 50.0)
	var factor: float = _storm_stats.chain_lightning_dist_factor
	var damage_multiplier: float = (factor * distance) / 100.0
	var final_damage: float = original_damage * damage_multiplier
	
	var spell_modifiers: Dictionary = {
		Spell.ChainLightningModifier.DAMAGE: final_damage,
		Spell.ChainLightningModifier.BOUNCE_COUNT: 3, # Par exemple
		Spell.ChainLightningModifier.BOUNCE_RANGE: 150.0,
		Spell.ChainLightningModifier.DAMAGE_DECAY_PERCENT: 10.0,
		"start_position": victim_pos
	}
	_owner.cast_spell(furthest_enemy, Spell.Type.CHAIN_LIGHTNING, spell_modifiers)
	
#region ============================== Callbacks functions ==============================

func _on_current_rank_changed() -> void:
	_call_the_lightning()
	# [STORM BREAKER]
	if _storm_stats.storm_breaker_activated:
		_apply_storm_breaker_effect()
	# [STORM BATTERY]
	if _storm_stats.storm_battery_activated:
		_apply_storm_battery_effect()
	# [DYNAMO]
	if _storm_stats.dynamo_activated:
		_apply_dynamo_effect()
	# [THUNDER BERSERKER] (Pénalité sur Grind)
	if _storm_stats.thunder_berserker_activated and _thunder_berserker_penalty_active:
		_apply_thunder_berserker_penalty()
	match _current_rank:
		Rank.S:
			var duration: float = RANK_S_DURATION
			# [THUNDER STORM]
			if _storm_stats.thunder_storm_activated:
				duration += _storm_stats.thunder_storm_duration_bonus
				
			# [EYE OF THE CYCLONE]
			if _storm_stats.eye_of_the_cyclone_activated:
				_apply_eye_of_the_cyclone_effect()

			_rank_s_duration_timer.wait_time = duration
			_rank_s_duration_timer.start()
			_lightning_spam_timer.start()
		_:
			_lightning_spam_timer.stop()

func _on_lightning_spam_timer_timeout() -> void:
	_call_the_lightning()
	
func _on_rank_s_timer_timeout() -> void:
	_current_point = 0
	_current_rank = Rank.D

func _on_owner_critical_action_done(_entity_ref: Entity, _target: Entity, _action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	# [CHAIN LIGHTNING]
	if _storm_stats.chain_lightning_activated:
		var chance: float = _storm_stats.chain_lightning_chance_percent
		if Utils.is_randomize_modifier_active(chance):
			_apply_chain_lightning_effect(_target, real_value)
			
	# [LIGHTNING FOOTWORK]
	if _storm_stats.lightning_footwork_activated:
		_lightning_footwork_current_bonus += _storm_stats.lightning_footwork_dodge_increase
		_update_lightning_footwork_modifier()

	# [RANK]
	if _current_rank != Rank.S:
		var points_gained: float = _get_crit_point(base_value, real_value)
		
		# [QUICKCHARGE]
		if _storm_stats.quickcharge_activated:
			points_gained *= (1.0 + _storm_stats.quickcharge_grind_percent / 100.0)
			
		_current_point += points_gained
		
		if _current_point >= RANK_POINT_TRESHOLDS[Rank.S]: _current_rank = Rank.S
		elif _current_point >= RANK_POINT_TRESHOLDS[Rank.A]: _current_rank = Rank.A
		elif _current_point >= RANK_POINT_TRESHOLDS[Rank.B]: _current_rank = Rank.B
		elif _current_point >= RANK_POINT_TRESHOLDS[Rank.C]: _current_rank = Rank.C
			
func _on_thunder_berserker_timeout() -> void:
	_thunder_berserker_penalty_active = true

func _on_dodge_lightning_footwork(_cb_vars: Dictionary) -> void:
	# [LIGHTNING FOOTWORK]
	_lightning_footwork_current_bonus = 0.0
	_update_lightning_footwork_modifier()


#endregion
