class_name ColossusManager
extends FamilyManager

# --- STATS PASSIVES (Dépendent du Niveau de la famille [0, 1, 2, 3, 4]) ---
const HP_MAX_INCREASE: Array[float] = [15.0, 20.0, 35.0, 50.0]
const SIZE_DEFENSE_INCREASE: Array[float] = [10.0, 20.0, 30.0, 40.0]


#region ============================== public API ==============================
func start() -> void:
	Verbose.debug("ColossusManager start", Verbose.Category.FAMILY_MANAGER)
	
	if level >= 1 :
		_start_passive()

func stop() -> void:
	Verbose.debug("ColossusManager stop", Verbose.Category.FAMILY_MANAGER)
#endregion


func _start_passive() -> void:

	# Register the initial stat modifier (value 0 — updated each tick)
	var mod := StatModifier.new()
	mod.id = &"Colossus Passive HPMAX"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _owner.stats.health_max * (HP_MAX_INCREASE[level - 1] / 100)
	_owner.stat_modifiers_registry.register_modifier(mod)
	
	var mod2 := StatModifier.new()
	mod2.id = &"Colossus Passive HP"
	mod2.stat_type = EntityStats.StatType.HEALTH
	mod2.calc_type = StatModifier.CalcType.ADD
	mod2.value = _owner.stats.health * (HP_MAX_INCREASE[level - 1] / 100)
	_owner.stat_modifiers_registry.register_modifier(mod2)
	
	var mod3 := StatModifier.new()
	mod3.id = &"Colossus Passive Defense"
	mod3.stat_type = EntityStats.StatType.DEFENCE
	mod3.calc_type = StatModifier.CalcType.ADD
	mod3.value = _owner.stats.defence * (SIZE_DEFENSE_INCREASE[level - 1] / 100)
	_owner.stat_modifiers_registry.register_modifier(mod3)
	
	
	var ratio_scaling: float = _owner.scale[1] + (SIZE_DEFENSE_INCREASE[level - 1] / 100)
	print(str(ratio_scaling)) # c'est = à 1.X
	
	print("Size du dark knight: " + str(_owner.scale)) 
	_owner.scale = Vector3(ratio_scaling, ratio_scaling, ratio_scaling) 
	print("Size du dark knight: " + str(_owner.scale))
	print("Size du dark knight: " + str(_owner.scale[1])) # pas egal à 1.X
