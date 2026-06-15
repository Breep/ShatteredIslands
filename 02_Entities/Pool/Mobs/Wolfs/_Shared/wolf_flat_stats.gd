class_name WolfFlatStats
extends RefCounted

# Helper partagé des loups : applique et décrit un dictionnaire de bonus de stats plats
# (clé = StatType ciblée, valeur = montant ajouté en ADD). Mutualisé par les talents qui
# accordent des bonus de stats (Bronze, Gold, Ultimate) pour rester data-driven : on
# choisit les stats visées directement dans le .tres, sans toucher au code.


static func apply_bonuses(entity: Entity, bonuses: Dictionary[EntityStats.StatType, float], id_prefix: StringName) -> void:
	if entity == null or entity.stat_modifiers_registry == null:
		return
	for stat: EntityStats.StatType in bonuses:
		var mod := StatModifier.new()
		mod.id = StringName("%s_%d" % [id_prefix, stat])
		mod.stat_type = stat
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = bonuses[stat]
		entity.stat_modifiers_registry.register_modifier(mod)


# Construit "+X stat, +Y stat" coloré pour les descriptions. value_formatter = SkillEffect._value.
static func describe_bonuses(bonuses: Dictionary[EntityStats.StatType, float], value_formatter: Callable) -> String:
	var parts: PackedStringArray = []
	for stat: EntityStats.StatType in bonuses:
		parts.append("+" + value_formatter.call(bonuses[stat]) + " " + stat_label(stat))
	return ", ".join(parts)


static func stat_label(stat: EntityStats.StatType) -> String:
	match stat:
		EntityStats.StatType.CRIT_CHANCE: return "[[CRIT_CHANCE]]"
		EntityStats.StatType.CRIT_MULT: return "[[CRIT_MULTIPLIER]]"
		EntityStats.StatType.DODGE: return "[[DODGE]]"
		EntityStats.StatType.ARMOR: return "[[ARMOR]]"
		EntityStats.StatType.MAGIC_RESIST: return "[[MR]]"
		EntityStats.StatType.POISON_RESIST: return "[[POISON_RESISTANCE]]"
		EntityStats.StatType.SCALE: return "[[SCALE]]"
		EntityStats.StatType.AD: return "[[WARRIOR]]"
		EntityStats.StatType.MANA_MAX, EntityStats.StatType.MANA: return "[[MANA]]"
		EntityStats.StatType.AS: return "vitesse d'attaque"
		EntityStats.StatType.MS: return "vitesse de déplacement"
		EntityStats.StatType.AP: return "puissance magique"
		EntityStats.StatType.HEALTH_MAX: return "PV max"
		EntityStats.StatType.LIFESTEAL: return "vol de vie"
		EntityStats.StatType.MANA_REGEN: return "régénération de mana"
		_: return EntityStats.StatType.keys()[stat]
