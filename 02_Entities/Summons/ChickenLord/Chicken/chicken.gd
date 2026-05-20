class_name Chicken
extends Summon

enum Type {
	BASIC,
	GIFTED_ATTACK,
	GIFTED_STORM_CALLER,
	GIFTED_POISON,
	GIFTED_ARDENT_CELESTIAL,
	GIFTED_COLOSSUS,
	GIFTED_LIGHT,
	GIFTED_ENGINEER,
	GIFTED_NECROSIS
}

var _base_health_max: float
var _base_ad: float
var _base_armor: float
var _base_crit_chance: float
var _base_crit_multi: float

enum BaseStatsModifier {
	HP,
	AD,
	ARMOR,
	CRIT_CHANCE,
	CRIT_MULTI
}

func _ready() -> void:
	_register_base_stat_modifier(&"Chicken_base_hp", EntityStats.StatType.HEALTH_MAX, _base_health_max)
	_register_base_stat_modifier(&"Chicken_base_ad", EntityStats.StatType.AD, _base_ad)
	_register_base_stat_modifier(&"Chicken_base_armor", EntityStats.StatType.ARMOR, _base_armor)
	_register_base_stat_modifier(&"Chicken_base_crit_chance", EntityStats.StatType.CRIT_CHANCE, _base_crit_chance)
	_register_base_stat_modifier(&"Chicken_base_crit_multi", EntityStats.StatType.CRIT_MULT, _base_crit_multi)

	super._ready()
	
	
func set_base_stats(hp: float, ad: float, armor: float, crit_chance: float, crit_multi: float) -> void:
	_base_health_max = hp
	_base_ad = ad
	_base_armor = armor
	_base_crit_chance = crit_chance
	_base_crit_multi = crit_multi


func _register_base_stat_modifier(mod_id: StringName, stat_type: EntityStats.StatType, mod_value: float, action_type: int = -1) -> void:
	var mod := StatModifier.new()
	mod.id = mod_id
	mod.stat_type = stat_type
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = mod_value
	mod.tags = []
	if action_type != -1:
		mod.action_type = action_type as Utils.ActionType
	stat_modifiers_registry.register_modifier(mod)
