extends Card

@export var _base_threshold: Array[float] = [70.0, 65.0, 60.0, 55.0, 50.0]
@export var _base_resistance: Array[float] = [20.0, 25.0, 30.0, 35.0, 50.0]

func _get_description_per_level(level: int) -> String:
	var t = Utils.format_float(_base_threshold[level - 1], 0)
	var r = Utils.format_float(_base_resistance[level - 1], 0)
	return "When HP > %s%%, gain %s Critical Resistance." % [t, r]

func apply(owner: Entity, level: int) -> void:
	if owner == null: return
	
	var stats: FamilyStormStats = owner.stats_manager.get_family_stats("Storm")
	
	stats.lightning_rod_activated = true
	stats.lightning_rod_hp_threshold_percent = _base_threshold[level - 1]
	stats.lightning_rod_resistance_amount = _base_resistance[level - 1]
	
	# Force an update in manager by signaling health change?
	# Or relies on next health update. 
	# To be safe, the manager should check conditions on start or stat update.
