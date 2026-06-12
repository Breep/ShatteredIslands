class_name SE_BenevolentAggression
extends SkillEffect

@export var _proc_chance: float = 20.0
@export var _ap_heal_ration: float = 1.0
var _forest_drake: ForestDrake

func apply(ctx: SkillContext) -> void:
	_forest_drake = ctx.entity
	
	var mod:= AutoAttackModifier.new()
	mod.id = &"BenevolentAggression"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not is_instance_valid(_forest_drake): return
		if not Utils.is_randomize_modifier_active(_proc_chance, _forest_drake.battle_id): return
		var source = cb_vars.get(AutoAttackModifier.VarType.SOURCE)
		if is_instance_valid(source): return
		_forest_drake.heal.direct(source, _ap_heal_ration * _forest_drake.stats.attack_power, &"Benevolent Aggression")
	_forest_drake.aura.add_modifier(mod)


func get_description() -> String:
	return "Quand un allié auto-attaque, " + _value(_proc_chance) + "% de chance de le " \
		+ "soigner de " + _value(_ap_heal_ration * 100) + "% de la puissance magique du drake."
