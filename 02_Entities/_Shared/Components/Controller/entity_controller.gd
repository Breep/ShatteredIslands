class_name EntityController
extends EntityComponent

# Parent "manette" qui pilote l'entité en mode AUTO (AIController) ou MANUAL
# (PlayerController). Les deux enfants existent en permanence ; l'un est actif
# selon le mode + la sélection :
#   - AUTO          → AIController actif
#   - MANUAL + selected → PlayerController actif
#   - MANUAL non selected → ni l'un ni l'autre (entité "inerte", attend une sélection)
#
# `_is_selected` est piloté par un système extérieur (le proto sélectionne via clic
# court) : permet d'avoir plusieurs entités configurées en MANUAL sans qu'elles
# réagissent toutes ensemble à un right-click.

#region ============================== Enums ==============================
enum Mode { AUTO, MANUAL }
#endregion


#region ============================== Private variables ==============================
var _mode: Mode = Mode.AUTO

@export var _ai: AIController = null
@export var _player: PlayerController = null
#endregion


#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.controller != null and _owner.controller != self:
		Verbose.trace("Override: EntityController on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.controller.queue_free()
	_owner.controller = self
	
	if _ai == null:
		Verbose.error("EntityController on [" + _owner.entity_name + "] has no AIController", Verbose.Category.ENTITY_MODULE)
		return
	if _player == null:
		Verbose.error("EntityController on [" + _owner.entity_name + "] has no PlayerController", Verbose.Category.ENTITY_MODULE)
		return
	
	_ai.init(_owner)
	_player.init(_owner)


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.controller != self:
		return
#endregion


#region ============================== Public API ==============================
func set_mode(new_mode: Mode) -> void:
	_mode = new_mode
	Verbose.debug("EntityController on [" + _owner.entity_name + "] set_mode " + Mode.find_key(new_mode), Verbose.Category.ENTITY_MODULE)
	_apply_state()


## Coupe les deux enfants. Le mode/selected restent mémorisés pour un futur set.
func disable() -> void:
	if _ai != null: _ai.disable()
	if _player != null: _player.disable()
#endregion


#region ============================== Private functions ==============================
func _apply_state() -> void:
	match _mode:
		Mode.AUTO:
			if _ai: _ai.enable()
			if _player: _player.disable()
		Mode.MANUAL:
			if _ai: _ai.disable()
			if _player: _player.enable()
#endregion
