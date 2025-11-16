class_name PoisonAntidote
extends CharacterUpgrade

@export var _damage_deacrease: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Antidote: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_antidote_activated = true
	stats.poison.poison_antidote_decrease = _damage_deacrease[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Antidote: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Decrease [[POISON_DAMAGE]] received by " + str(_damage_deacrease[cardlvl - 1]) + "%"


func _on_purchase(cb_vars: Dictionary) -> void:
	if not cb_vars.has(VarType.STAT_MODIFIERS_MANAGER): return
	if not cb_vars.has(VarType.FAMILIES_STATS): return
	var stat_modifier_manager: EntityStatsManager = cb_vars[VarType.STAT_MODIFIERS_MANAGER]
	var poison_stats: FamilyPoisonStats = cb_vars[VarType.STAT_MODIFIERS_MANAGER].poison
	var mod := StatModifier.new()
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = poison_stats.poison_antidote_decrease
	mod.stat_type = EntityStats.StatType.RESISTANCE
	mod.action_type = Utils.ActionType.DAMAGE_POISON
	mod.id = "Antidote"
	stat_modifier_manager.update_modifier(mod)
