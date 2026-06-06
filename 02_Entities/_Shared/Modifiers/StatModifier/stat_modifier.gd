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


func clone() -> Modifier:
	var c := StatModifier.new()
	c.id = id
	c.tags = tags.duplicate()
	c.stat_type = stat_type
	c.action_type = action_type
	c.calc_type = calc_type
	c.value = value
	return c
