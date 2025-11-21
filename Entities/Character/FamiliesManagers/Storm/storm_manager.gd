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

const CRIT_POINT_DEFAULT: float = 1.0 # How many point does a crit is worth by default
const CRIT_POINT_MULT: float = 0.5 # How many point does a multiplier is worth

const RANK_POINT_TRESHOLDS: Dictionary[Rank, float] = {
	Rank.D: 0.0,
	Rank.C: 5.0,
	Rank.B: 15.0,
	Rank.A: 30.0,
	Rank.S: 50.0
}

const RANK_S_DURATION: float = 0.5

const GLOBAL_CRIT_MULTIPLIER_BOOSTS: Dictionary[Rank, Array] = {
	Rank.D: [10, 15, 20, 25],
	Rank.C: [20, 30, 40, 50],
	Rank.B: [30, 45, 60, 75],
	Rank.A: [40, 60, 80, 100],
	Rank.S: [50, 75, 100, 125]
}

const GLOBAL_CRIT_CHANCE_BOOSTS: Dictionary[Rank, Array] = {
	Rank.D: [1, 1.5, 2, 2.5],
	Rank.C: [2, 3.0, 4, 5.0],
	Rank.B: [3, 4.5, 6, 7.5],
	Rank.A: [4, 6.0, 8, 10.0],
	Rank.S: [5, 7.5, 10, 12.5]
}

const LIGHTNING_DAMAGE_PERCENT: Array[float] = [150, 200, 300, 400]

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
var _current_point: float

# ============================== Local Nodes ==============================

@onready var _rank_s_timer: Timer = %RankSTimer

# ============================== Public functions ==============================

func _ready() -> void:
	_storm_stats = _owner.families_stats.storm
	_owner.critical_action_done.connect(_on_owner_critical_action_done)


func start() -> void:
	_apply_passive_crit_boost()
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()

# ============================== Private functions ==============================
#region on battle start
#endregion

#region optional timer
func _create_optional_timers() -> void:
	pass
#endregion

#region aa modifier
#endregion

#region stats modifier
#endregion

#region actions modifier
#endregion

#region others cards
#endregion

func _reset_rank() -> void:
	_current_point = Rank.D
	_current_point = 0

#region ============================== Callbacks functions ==============================

func _on_current_rank_changed() -> void:
	_call_the_lightning()
	_apply_passive_crit_boost()
	match _current_rank:
		Rank.D: pass
		Rank.C: pass
		Rank.B: pass
		Rank.A: pass
		Rank.S:
			_rank_s_timer.start()


func _on_rank_s_timer_timeout() -> void:
	_current_rank = Rank.D
	_current_point = 0


func _on_owner_critical_action_done(_entity_ref: Entity, _target: Entity, _action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	#print("StormManager: CRIT DONE on ", target, " A=", action_type, " | ", base_value, "/", real_value, " | Points=", _get_crit_point(base_value, real_value))
	_current_point += _get_crit_point(base_value, real_value)
	#print("StormManager: ", _current_point)
	if _current_point >= RANK_POINT_TRESHOLDS[Rank.S]: _current_rank = Rank.S
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.A]: _current_rank = Rank.A
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.B]: _current_rank = Rank.B
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.C]: _current_rank = Rank.C
#endregion

#region ============================== Private functions ==============================
func _get_crit_point(default_damage: float, real_damage: float) -> float:
	if real_damage < 0: return 0
	if default_damage < 1.0: CRIT_POINT_DEFAULT
	return CRIT_POINT_DEFAULT + (real_damage / default_damage) * CRIT_POINT_MULT


func _apply_passive_crit_boost() -> void:
	for action_type in Utils.get_all_actions():
		var crit_chance_boost := StatModifier.new()
		crit_chance_boost.stat_type = EntityStats.StatType.CRIT_CHANCE
		crit_chance_boost.action_type = action_type
		crit_chance_boost.calc_type = StatModifier.CalcType.ADD
		crit_chance_boost.id = "Lightning passive"
		crit_chance_boost.tags = [StatModifier.TagType.FAMILY]
		crit_chance_boost.value = GLOBAL_CRIT_CHANCE_BOOSTS[_current_rank][3]
		_owner.stats_manager.update_modifier(crit_chance_boost)
		
		var crit_multiplier_boost := StatModifier.new()
		crit_multiplier_boost.stat_type = EntityStats.StatType.CRIT_MULT
		crit_multiplier_boost.action_type = action_type
		crit_multiplier_boost.calc_type = StatModifier.CalcType.ADD
		crit_multiplier_boost.id = "Lightning passive"
		crit_multiplier_boost.tags = [StatModifier.TagType.FAMILY]
		crit_multiplier_boost.value = GLOBAL_CRIT_MULTIPLIER_BOOSTS[_current_rank][3]
		_owner.stats_manager.update_modifier(crit_multiplier_boost)


func _call_the_lightning() -> void:
	var target: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var damage: float = _owner.stats.attack_damage * LIGHTNING_DAMAGE_PERCENT[0] / 100.0
	_owner.cast_spell(target, Spell.Type.LIGHTNING, { Spell.LightningModifier.DAMAGE: damage })
#endregion
