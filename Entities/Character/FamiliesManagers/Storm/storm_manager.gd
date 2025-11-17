class_name StormManager
extends FamilyManager

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
	Rank.C: 10.0,
	Rank.B: 15.0,
	Rank.A: 25.0,
	Rank.S: 50.0
}

const RANK_S_DURATION: float = 0.5

# ============================== Private variables ==============================

var _storm_stats: FamilyStormStats

var __current_rank: Rank = Rank.D
var _current_rank: Rank:
	get: return __current_rank
	set(value):
		if __current_rank == value: return
		__current_rank = value
		_on_current_rank_changed()
var _current_point: float

# ============================== Local Nodes ==============================

@onready var _rank_s_timer: Timer = %RankSTimer

# ============================== Public functions ==============================

func _ready() -> void:
	_storm_stats = _owner.families_stats.storm
	_owner.critical_action_done.connect(_on_owner_critical_action_done)


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	pass


func _reset_rank() -> void:
	_current_point = Rank.D
	_current_point = 0

# ============================== Callbacks functions ==============================

func _on_current_rank_changed() -> void:
	match _current_rank:
		Rank.D: print("StormManager: Rank D")
		Rank.C: print("StormManager: Rank C")
		Rank.B: print("StormManager: Rank B")
		Rank.A: print("StormManager: Rank A")
		Rank.S:
			_rank_s_timer.start()
			print("StormManager: Rank S")


func _on_owner_critical_action_done(_entity_ref: Entity, _target: Entity, _action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	#print("StormManager: CRIT DONE on ", target, " A=", action_type, " | ", base_value, "/", real_value, " | Points=", _get_crit_point(base_value, real_value))
	_current_point += _get_crit_point(base_value, real_value)
	print("StormManager: ", _current_point)
	if _current_point >= RANK_POINT_TRESHOLDS[Rank.S]: _current_rank = Rank.S
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.A]: _current_rank = Rank.A
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.B]: _current_rank = Rank.B
	elif _current_point >= RANK_POINT_TRESHOLDS[Rank.C]: _current_rank = Rank.C


func _get_crit_point(default_damage: float, real_damage: float) -> float:
	if real_damage < 0: return 0
	if default_damage < 1.0: CRIT_POINT_DEFAULT
	return CRIT_POINT_DEFAULT + (real_damage / default_damage) * CRIT_POINT_MULT


func _on_rank_s_timer_timeout() -> void:
	_current_rank = Rank.D
	_current_point = 0
