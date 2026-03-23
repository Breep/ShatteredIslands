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

func set_basic_stats(chicken_family_level: int) -> void:
	if chicken_family_level < 0 or chicken_family_level > 4:
		Verbose.error("Entity [" + entity_name + "] initialized at invalid family level.", Verbose.Category.ENTITY)
		return 
	stats.attack_damage 
