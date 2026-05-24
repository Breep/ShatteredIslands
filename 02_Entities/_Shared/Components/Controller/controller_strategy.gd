class_name ControllerStrategy
extends Node

# Base des "modes" du EntityController (AI, Player...). Pas un EntityComponent :
# c'est un enfant statique de EntityController dans son .tscn, l'owner est propagé
# par le parent via init() au moment où le parent entre dans l'arbre.

#region ============================== Private variables ==============================
var _owner: Entity = null
var _active: bool = false
#endregion


#region ============================== Public API ==============================
func init(entity: Entity) -> ControllerStrategy:
	_owner = entity
	return self


func enable() -> void:
	_active = true


func disable() -> void:
	_active = false


func is_active() -> bool:
	return _active
#endregion
