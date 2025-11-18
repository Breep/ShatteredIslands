class_name StormManager
extends FamilyManager

# ============================== Constants ==============================

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


# ============================== Callbacks functions ==============================

func _on_owner_critical_action_done(_entity_ref: Entity, target: Entity, action_type: Utils.ActionType, value: float) -> void:
	print("CRIT DONE on ", target, " A=", action_type, " V=", value)
