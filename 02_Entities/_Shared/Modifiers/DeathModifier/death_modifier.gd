# Modifier déclenché à la mort de l'entité via DeathModifiersRegistry.
# Le registre consomme tous les modifiers en death event ; chaque modifier
# exécute son after_action_logic_callback.
class_name DeathModifier
extends Modifier

var is_one_time_effect: bool = true

var after_action_logic_callback := Callable() # var: Dictionary
