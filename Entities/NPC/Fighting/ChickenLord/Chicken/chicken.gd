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

enum BaseStatsModifier {
	HP,
	AD,
	ARMOR,
	CRIT_CHANCE,
	CRIT_MULTI
}

func set_base_stats(hp: float, ad: float, armor: float, crit_chance: float, crit_multi: float) -> void:
	#if chicken_family_level < 0 or chicken_family_level > 4:
		#Verbose.error("Entity [" + entity_name + "] initialized at invalid family level.", Verbose.Category.ENTITY)
		#return
	base_stats.health_max = hp
	base_stats.attack_damage = ad
	base_stats.update_stat(EntityStats.StatType.RESISTANCE, armor, Utils.ActionType.DAMAGE_PHYSICAL)
	base_stats.update_stat(EntityStats.StatType.CRIT_CHANCE, crit_chance, Utils.ActionType.DAMAGE_PHYSICAL)
	base_stats.update_stat(EntityStats.StatType.CRIT_MULT, crit_multi, Utils.ActionType.DAMAGE_PHYSICAL)
