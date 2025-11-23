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

const RANK_S_DURATION: float = 5.0 
const RANK_S_LIGHTNING_COOLDOWN: float = 0.1

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const GLOBAL_CRIT_MULTIPLIER_BOOSTS: Array[float] = [25.0, 50.0, 75.0, 100.0]
const GLOBAL_CRIT_CHANCE_BOOSTS: Array[float] = [2.5, 2.5, 5.0, 7.5, 10.0]
const BASE_LIGHTNING_DAMAGE_PERCENT: Array[float] = [150.0, 150.0, 200.0, 300.0, 400.0]

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

# ============================== Local Nodes ==============================

@onready var _rank_s_duration_timer: Timer = %RankSTimer

# ============================== Public functions ==============================

func _ready() -> void:
	_storm_stats = _owner.families_stats.storm
	_owner.critical_action_done.connect(_on_owner_critical_action_done)
	_create_optional_timers()

func start() -> void:
	_apply_passive_crit_boost()
	for timer in _optional_timers:
		timer.start()
	_storm_breaker_memory.clear()

func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	if _lightning_spam_timer:
		_lightning_spam_timer.stop()

# ============================== Private functions ==============================

#region optional timer
func _create_optional_timers() -> void:
	_lightning_spam_timer = Timer.new()
	_lightning_spam_timer.wait_time = RANK_S_LIGHTNING_COOLDOWN
	_lightning_spam_timer.one_shot = false
	_lightning_spam_timer.timeout.connect(_on_lightning_spam_timer_timeout)
	add_child(_lightning_spam_timer)
	
#endregion

#region stats modifier

func _apply_passive_crit_boost() -> void:
	pass
	#var current_lvl: int = _storm_stats.level 
	#
	## Sécurité pour ne pas dépasser la taille du tableau
	#current_lvl = clamp(current_lvl, 0, GLOBAL_CRIT_CHANCE_BOOSTS.size() - 1)
#
	#for action_type in Utils.get_all_actions():
		## 1. Crit Chance (Fixe selon le niveau)
		#var crit_chance_boost := StatModifier.new()
		#crit_chance_boost.stat_type = EntityStats.StatType.CRIT_CHANCE
		#crit_chance_boost.action_type = action_type
		#crit_chance_boost.calc_type = StatModifier.CalcType.ADD
		#crit_chance_boost.id = "Lightning passive Chance"
		#crit_chance_boost.tags = [StatModifier.TagType.FAMILY]
		#crit_chance_boost.value = GLOBAL_CRIT_CHANCE_BOOSTS[current_lvl] 
		#_owner.stats_manager.update_modifier(crit_chance_boost)
		#
		## 2. Crit Multiplier (Fixe selon le niveau)
		#var crit_multiplier_boost := StatModifier.new()
		#crit_multiplier_boost.stat_type = EntityStats.StatType.CRIT_MULT
		#crit_multiplier_boost.action_type = action_type
		#crit_multiplier_boost.calc_type = StatModifier.CalcType.ADD
		#crit_multiplier_boost.id = "Lightning passive Mult"
		#crit_multiplier_boost.tags = [StatModifier.TagType.FAMILY]
		#crit_multiplier_boost.value = GLOBAL_CRIT_MULTIPLIER_BOOSTS[current_lvl]
		#_owner.stats_manager.update_modifier(crit_multiplier_boost)
		
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
	
	_owner.cast_spell(target, Spell.Type.LIGHTNING, { Spell.LightningModifier.DAMAGE: damage })

# [STORM BREAKER]
func _apply_storm_breaker_effect() -> void:
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null or not is_instance_valid(target): return
	
	# Multiplicateur de Rang s'applique ici
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

# [STORM BATTERY]
func _apply_storm_battery_effect() -> void:
	if _owner == null or not is_instance_valid(_owner): return
	
	# Multiplicateur de Rang s'applique ici
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	
	var base_mana: float = _storm_stats.storm_battery_mana_gain
	var final_mana: float = base_mana * rank_mult
	
	if final_mana > 0:
		_owner.stats.mana += final_mana

#endregion

#region ============================== Callbacks functions ==============================

func _on_current_rank_changed() -> void:
	_call_the_lightning()
	
	# [STORM BREAKER]
	if _storm_stats.storm_breaker_activated:
		_apply_storm_breaker_effect()
		
	# [STORM BATTERY]
	if _storm_stats.storm_battery_activated:
		_apply_storm_battery_effect()
		
	match _current_rank:
		Rank.S:
			_rank_s_duration_timer.wait_time = RANK_S_DURATION
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
	if _current_rank == Rank.S: return 
	
	_current_point += _get_crit_point(base_value, real_value)
	
	if _current_point >= RANK_POINT_TRESHOLDS[Rank.S]: _current_rank = Rank.S
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.A]: _current_rank = Rank.A
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.B]: _current_rank = Rank.B
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.C]: _current_rank = Rank.C
	
#endregion
