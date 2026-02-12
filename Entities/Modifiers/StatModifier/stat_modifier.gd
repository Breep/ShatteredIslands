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
	EVENT,
	FAMILY
}

# ============================== Public variables ==============================

var stat_type: EntityStats.StatType
var action_type: Utils.ActionType # Used for action specific stats (For multiStats like Crit or DODGE)
var id: StringName
var calc_type: CalcType
var value: float
var tags: Array[TagType]
var auto_cleanup: bool = true
