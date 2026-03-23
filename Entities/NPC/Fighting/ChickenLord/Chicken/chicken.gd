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
	base_stats.health_max = _base_health_max
	base_stats.attack_damage = _base_ad
	base_stats.update_stat(EntityStats.StatType.RESISTANCE, _base_armor, Utils.ActionType.DAMAGE_PHYSICAL)
	base_stats.update_stat(EntityStats.StatType.CRIT_CHANCE, _base_crit_chance, Utils.ActionType.DAMAGE_PHYSICAL)
	base_stats.update_stat(EntityStats.StatType.CRIT_MULT, _base_crit_multi, Utils.ActionType.DAMAGE_PHYSICAL)
	stat_modifiers_registry.recompute_all()
	super._ready()
	
	
func set_base_stats(hp: float, ad: float, armor: float, crit_chance: float, crit_multi: float) -> void:
	_base_health_max = hp
	_base_ad = ad
	_base_armor = armor
	_base_crit_chance = crit_chance
	_base_crit_multi = crit_multi
