class_name EntityController
extends EntityComponent

# Base "manette" qui pilote l'entité en lui donnant des ordres haut niveau
# (set la cible AA, demander un déplacement). Sous-classes : AIController
# (décisions auto), PlayerController (input joueur). Une seule instance active
# à la fois sur une entité — l'éviction de _enter_tree garantit l'unicité.
#
# enable()/disable() activent/désactivent les prises de décision sans toucher
# aux ordres standing déjà donnés (la cible AA courante reste, seules les
# futures décisions sont mises en pause).

#region ============================== Private variables ==============================
var _active: bool = false
#endregion


#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.controller != null and _owner.controller != self:
		Verbose.trace("Override: EntityController on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.controller.queue_free()
	_owner.controller = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.controller != self:
		return
#endregion


#region ============================== Public API ==============================
func enable() -> void:
	_active = true


func disable() -> void:
	_active = false


func is_active() -> bool:
	return _active
#endregion
