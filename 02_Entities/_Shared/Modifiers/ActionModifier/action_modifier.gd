# Modifier d'action (damage/heal/dodge/summon/spell/stack) appliqué via
# ActionModifiersRegistry. Intercepte une action avant et/ou après son
# exécution via callbacks, ou injecte des effets visuels.
class_name ActionModifier
extends Modifier

enum VarType { # Variable types of the callbacks dictionary
	VISUAL_POS,
	PHYSICAL_DAMAGE,
	STACK_VALUE,
	STACK_TYPE,
	TARGET,
	DODGE_NUMBER,
	HEAL_AMOUNT,
	DURATION,
	ENTITY_TYPE,
	ENTITY_MODIFIER,
	SPELL_TYPE,
	SPELL_MODIFIER,
}


var action_type: Utils.ActionCategory
var is_one_time_effect: bool = true

var before_action_logic_callback := Callable() # var: Dictionary
var after_action_logic_callback := Callable() # var: Dictionary
var visual_callback := Callable() # var: Dictionary
