# Modifier déclenché à la mort de l'entité via DeathModifiersRegistry.
# Le registre consomme tous les modifiers en death event ; chaque modifier
# exécute son after_action_logic_callback.
class_name DeathModifier
extends Modifier

var is_one_time_effect: bool = true

var after_action_logic_callback := Callable() # var: Dictionary


func clone() -> Modifier:
	var c := DeathModifier.new()
	c.id = id
	c.tags = tags.duplicate()
	c.is_one_time_effect = is_one_time_effect
	c.after_action_logic_callback = after_action_logic_callback
	return c
