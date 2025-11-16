class_name StormManager
extends FamilyManager

# ============================== Constants ==============================

const CRIT_POINT_DEFAULT: float = 1.0 # How many point does a crit is worth by default
const CRIT_POINT_MULT: float = 1.0 # How many point does a multiplier is worth

# ============================== Private variables ==============================

var _storm_stats: FamilyStormStats

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

# ============================== Callbacks functions ==============================

func _on_owner_critical_action_done(_entity_ref: Entity, target: Entity, action_type: Utils.ActionType, base_value: float, real_value: float) -> void:
	print("CRIT DONE on ", target, " A=", action_type, " | ", base_value, "/", real_value, " | Points=", _get_crit_point(base_value, real_value))


func _get_crit_point(default_damage: float, real_damage: float) -> float:
	if real_damage < 0: return 0
	if default_damage < 1.0: CRIT_POINT_DEFAULT
	return CRIT_POINT_DEFAULT + (real_damage / default_damage) * CRIT_POINT_MULT
