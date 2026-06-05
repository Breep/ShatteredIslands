# Modifier de stat appliqué à une entité via EntityStatModifiersRegistry.
# Compose calc_type (ADD/MULT) avec stat_type / action_type et une valeur.
class_name StatModifier
extends Modifier

# ============================== Enum ==============================

enum CalcType {
	ADD,
	MULT
}

# ============================== Public variables ==============================

var stat_type: EntityStats.StatType
var action_type: Utils.ActionType # Used for action specific stats (For multiStats like Crit or DODGE)
var calc_type: CalcType
var value: float
