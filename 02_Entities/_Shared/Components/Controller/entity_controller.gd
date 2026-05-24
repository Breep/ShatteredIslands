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
var _is_selected: bool = false
var _ai: ControllerStrategy = null
var _player: ControllerStrategy = null
#endregion


#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.controller != null and _owner.controller != self:
		Verbose.trace("Override: EntityController on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.controller.queue_free()
	_owner.controller = self

	# Propager _owner aux enfants AVANT que leur propre _enter_tree fire.
	# get_children() retourne les enfants statiques de la scène (déjà instanciés
	# au moment où le parent entre dans l'arbre).
	for child in get_children():
		if child is AIController:
			_ai = child as ControllerStrategy
			_ai.init(_owner)
			Verbose.debug("EntityController on [" + _owner.entity_name + "] bound AIController child", Verbose.Category.ENTITY_MODULE)
		elif child is PlayerController:
			_player = child as ControllerStrategy
			_player.init(_owner)
			Verbose.debug("EntityController on [" + _owner.entity_name + "] bound PlayerController child", Verbose.Category.ENTITY_MODULE)
	if _ai == null:
		Verbose.warn("EntityController on [" + _owner.entity_name + "] has no AIController child", Verbose.Category.ENTITY_MODULE)
	if _player == null:
		Verbose.warn("EntityController on [" + _owner.entity_name + "] has no PlayerController child", Verbose.Category.ENTITY_MODULE)


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


func set_selected(selected: bool) -> void:
	_is_selected = selected
	Verbose.debug("EntityController on [" + _owner.entity_name + "] set_selected " + str(selected), Verbose.Category.ENTITY_MODULE)
	_apply_state()


func get_mode() -> Mode:
	return _mode


func is_selected() -> bool:
	return _is_selected


## Coupe les deux enfants. Le mode/selected restent mémorisés pour un futur set.
func disable() -> void:
	if _ai != null: _ai.disable()
	if _player != null: _player.disable()
#endregion


#region ============================== Private functions ==============================
func _apply_state() -> void:
	var player_should_run: bool = (_mode == Mode.MANUAL and _is_selected)
	var ai_should_run: bool = (_mode == Mode.AUTO)

	if _ai != null:
		if ai_should_run: _ai.enable()
		else: _ai.disable()
	if _player != null:
		if player_should_run: _player.enable()
		else: _player.disable()
#endregion
