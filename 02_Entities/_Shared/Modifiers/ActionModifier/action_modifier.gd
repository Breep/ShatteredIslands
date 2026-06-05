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


func clone() -> Modifier:
	var c := ActionModifier.new()
	c.id = id
	c.tags = tags.duplicate()
	c.action_type = action_type
	c.is_one_time_effect = is_one_time_effect
	c.before_action_logic_callback = before_action_logic_callback
	c.after_action_logic_callback = after_action_logic_callback
	c.visual_callback = visual_callback
	return c
