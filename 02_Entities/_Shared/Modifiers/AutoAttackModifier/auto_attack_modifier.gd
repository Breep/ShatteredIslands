# Modifier d'auto-attaque appliqué via AutoAttackModifierRegistry. Combine
# un add/mul de dégâts avec deux callbacks (modification de dégâts + effet
# additionnel exécuté pendant l'attaque).
class_name AutoAttackModifier
extends Modifier

# ============================== Enum ==============================

enum VarType { # Variable types of the callbacks dictionary
	SOURCE,
	TARGET,
	POSITION,
	DAMAGE,
	DAMAGE_ADD,
	DAMAGE_MUL,
	PROJECTILE
}

# ============================== Public variables ==============================

var add: float # Flat damage add
var mul: float # % damage mult
var is_one_time_effect: bool = true

var damage_modifier_callback := Callable()
var additional_effect_callback := Callable() # var: Dictionary
