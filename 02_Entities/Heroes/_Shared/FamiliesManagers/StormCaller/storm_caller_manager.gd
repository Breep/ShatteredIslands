class_name StormCallerManager
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

var _storm_caller_stats: FamilyStormCallerStats

var __current_rank: Rank = Rank.D
var _current_rank: Rank:
	get: return __current_rank
	set(value):
		if __current_rank == value: return
		__current_rank = value
		_storm_caller_stats.current_rank = value
		rank_changed.emit(value)
		_on_current_rank_changed()

var _current_point: float = 0.0
var _lightning_spam_timer: Timer

# ============================== Local Nodes ==============================

@onready var _rank_s_duration_timer: Timer = %RankSTimer

# ============================== Public functions ==============================

func _ready() -> void:
	_storm_caller_stats = _owner.families_stats.storm_caller


func start() -> void:
	_owner.critical_action_done.connect(_on_owner_critical_action_done)
	_create_lightning_spam_timer()
	_storm_caller_stats.storm_breaker_memory.clear()
	_current_point = 0
	_current_rank = Rank.D


func stop() -> void:
	if _owner.critical_action_done.is_connected(_on_owner_critical_action_done):
		_owner.critical_action_done.disconnect(_on_owner_critical_action_done)
	if _lightning_spam_timer:
		_lightning_spam_timer.stop()
		_lightning_spam_timer.queue_free()
		_lightning_spam_timer = null
	_rank_s_duration_timer.stop()

# ============================== Private functions ==============================

func _create_lightning_spam_timer() -> void:
	_lightning_spam_timer = Timer.new()
	_lightning_spam_timer.wait_time = RANK_S_LIGHTNING_COOLDOWN
	_lightning_spam_timer.one_shot = false
	_lightning_spam_timer.timeout.connect(_on_lightning_spam_timer_timeout)
	add_child(_lightning_spam_timer)


func _get_crit_point(default_damage: float, real_damage: float) -> float:
	if level < 1: return 0
	if real_damage < 0: return 0
	if default_damage < 1.0: return CRIT_POINT_DEFAULT
	return CRIT_POINT_DEFAULT + (real_damage / default_damage) * CRIT_POINT_MULT


func _call_the_lightning() -> void:
	var target: Entity = _owner.target.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var current_lvl: int = level
	var base_percent: float = BASE_LIGHTNING_DAMAGE_PERCENT[current_lvl]
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	var final_percent: float = base_percent * rank_mult
	var damage: float = _owner.stats.attack_damage * final_percent / 100.0
	_owner.spell_sender.cast_spell(target, Spell.Type.LIGHTNING, {Spell.LightningModifier.DAMAGE: damage})

	# Iterate on_lightning_callbacks registered by cards
	for cb: Callable in _storm_caller_stats.on_lightning_callbacks:
		cb.call(target, _current_rank, rank_mult)

# ============================== Callbacks ==============================

func _on_current_rank_changed() -> void:
	if _lightning_spam_timer == null:
		return
	_call_the_lightning()

	# Iterate on_rank_change_callbacks registered by cards
	var rank_mult: float = RANK_VALUE_MULTIPLIERS.get(_current_rank, 1.0)
	for cb: Callable in _storm_caller_stats.on_rank_change_callbacks:
		cb.call(_current_rank, rank_mult)

	match _current_rank:
		Rank.S:
			var duration: float = RANK_S_DURATION + _storm_caller_stats.thunder_storm_duration_bonus

			# Iterate on_rank_s_callbacks registered by cards
			for cb: Callable in _storm_caller_stats.on_rank_s_callbacks:
				cb.call(rank_mult)

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


func _on_owner_critical_action_done(_target: Entity, _action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	# TODO Make cards listen to this signal like they do for action_done
	for cb: Callable in _storm_caller_stats.on_crit_callbacks:
		cb.call(_target, base_value, real_value)

	# Rank progression
	if _current_rank != Rank.S:
		var points_gained: float = _get_crit_point(base_value, real_value)

		# Quickcharge multiplier (set by card)
		if _storm_caller_stats.quickcharge_grind_percent > 0.0:
			points_gained *= (1.0 + _storm_caller_stats.quickcharge_grind_percent / 100.0)

		_current_point += points_gained

		if _current_point >= RANK_POINT_TRESHOLDS[Rank.S]: _current_rank = Rank.S
		elif _current_point >= RANK_POINT_TRESHOLDS[Rank.A]: _current_rank = Rank.A
		elif _current_point >= RANK_POINT_TRESHOLDS[Rank.B]: _current_rank = Rank.B
		elif _current_point >= RANK_POINT_TRESHOLDS[Rank.C]: _current_rank = Rank.C
