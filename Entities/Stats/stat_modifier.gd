class_name StatModifier
extends Resource

# ============================== Enum ==============================

enum CalcType {
	ADD,
	MULT
}

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

# ============================== Public variables ==============================

var stat_type: EntityStats.StatType
var id: StringName
var calc_type: CalcType
var value: float
var tags: Array[TagType]
