class_name ColossusManager
extends FamilyManager

# --- STATS PASSIVES (Dépendent du Niveau de la famille [1, 2, 3, 4]) ---
const HP_MAX_INCREASE: Array[float] = [15.0, 20.0, 35.0, 50.0]
const SCALE_INCREASE: Array[float] = [10.0, 20.0, 30.0, 40.0]
const DEFENCE_FLAT: Array[float] = [10, 15, 20, 30]

#region ============================== public API ==============================
func start() -> void:
	Verbose.debug("ColossusManager start", Verbose.Category.FAMILY_MANAGER)


func stop() -> void:
	Verbose.debug("ColossusManager stop", Verbose.Category.FAMILY_MANAGER)


func apply_passive() -> void:
	if level <= 0:
		return

	# HP max bonus (%)
	var hp_mod := StatModifier.new()
	hp_mod.id = &"Colossus Passive HP"
	hp_mod.stat_type = EntityStats.StatType.HEALTH_MAX
	hp_mod.calc_type = StatModifier.CalcType.MULT
	hp_mod.value = HP_MAX_INCREASE[level - 1] / 100.0
	_owner.stat_modifiers_registry.register_modifier(hp_mod)

	# Scale bonus (flat additive)
	var scale_mod := StatModifier.new()
	scale_mod.id = &"Colossus Passive Scale"
	scale_mod.stat_type = EntityStats.StatType.SCALE
	scale_mod.calc_type = StatModifier.CalcType.ADD
	scale_mod.value = SCALE_INCREASE[level - 1] / 100.0
	_owner.stat_modifiers_registry.register_modifier(scale_mod)

	if _owner.alterations != null:
		_owner.alterations.add_stack(Alteration.Type.DEFENSE, DEFENCE_FLAT[level - 1])

#endregion
