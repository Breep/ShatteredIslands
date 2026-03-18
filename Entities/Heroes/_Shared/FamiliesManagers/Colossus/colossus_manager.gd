class_name ColossusManager
extends FamilyManager

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const HP_MAX_INCREASE: Array[float] = [15.0, 20.0, 35.0, 50.0]
const SCALE_INCREASE: Array[float] = [10.0, 20.0, 30.0, 40.0]


#region ============================== public API ==============================
func start() -> void:
	Verbose.debug("ColossusManager start", Verbose.Category.FAMILY_MANAGER)
	

func stop() -> void:
	Verbose.debug("ColossusManager stop", Verbose.Category.FAMILY_MANAGER)
	

func apply_passive() -> void:

	if level <= 0: return
	# Register the initial stat modifier (value 0 — updated each tick)
	var mod := StatModifier.new()
	mod.id = &"Colossus Passive"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.MULT
	mod.value = HP_MAX_INCREASE[level - 1] / 100
	_owner.stat_modifiers_registry.register_modifier(mod)
	
	var _on_scale_changed: Callable
	_on_scale_changed = func(scale: float) -> void:
		var mod3 := StatModifier.new()
		mod3.id = &"Colossus Passive"
		mod3.stat_type = EntityStats.StatType.DEFENCE
		mod3.calc_type = StatModifier.CalcType.ADD
		mod3.value = (scale - 1) * 100
		_owner.stat_modifiers_registry.register_modifier(mod3)
		
	_owner.battle_callback_registry.register_battle_start(&"Colossus Passive", func() -> void:
		if not is_instance_valid(_owner): return
		if not _owner.stats.scale_changed.is_connected(_on_scale_changed):
			_owner.stats.scale_changed.connect(_on_scale_changed)
		
	)
	
	var mod4 := StatModifier.new()
	mod4.id = &"Colossus Passive"
	mod4.stat_type = EntityStats.StatType.SCALE
	mod4.calc_type = StatModifier.CalcType.ADD
	mod4.value = SCALE_INCREASE[level - 1] / 100
	_owner.stat_modifiers_registry.register_modifier(mod4)
	
#endregion
