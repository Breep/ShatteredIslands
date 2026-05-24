class_name ClickableComponent
extends EntityComponent

# Gère l'interaction click et hover sur une entité.
# - Mouse hover : toggle marker (hover) + cursor pointing hand
# - Left mouse press → tracked. Si release dans les SHORT_CLICK_THRESHOLD_S
#   secondes, on émet Events.entity_clicked (= clic court "intentionnel"). Sinon,
#   on ne fait rien (l'utilisateur est en train de faire un long press → DraggableComponent).
# - select() / deselect() exposés pour piloter le marker depuis l'extérieur (ex: proto).

#region ============================== Constants ==============================
const _SELECTION_MARKER_SCENE: PackedScene = preload("res://02_Entities/_Shared/Misc/selection_marker.tscn")
const SHORT_CLICK_THRESHOLD_S: float = 0.1
#endregion

#region ============================== Private variables ==============================
var _selection_marker_instance: Node3D = null
var _is_selected: bool = false
var _is_hovered: bool = false

# Track press en cours : démarré sur input_event de l'entité, terminé sur release global.
var _press_pending: bool = false
var _press_start_msec: int = 0
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.clickable != null and _owner.clickable != self:
		Verbose.trace("Override: ClickableComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.clickable.queue_free()
	_owner.clickable = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.clickable != self:
		return
	_owner.input_event.connect(_on_owner_input_event)
	_owner.mouse_entered.connect(_on_owner_mouse_entered)
	_owner.mouse_exited.connect(_on_owner_mouse_exited)
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	# Écoute uniquement les release LEFT pour finaliser un click pending.
	if not _press_pending: return
	if not (event is InputEventMouseButton): return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or mb.pressed: return

	var duration_s: float = float(Time.get_ticks_msec() - _press_start_msec) / 1000.0
	_press_pending = false
	set_process_unhandled_input(false)

	if duration_s < SHORT_CLICK_THRESHOLD_S:
		Events.entity_clicked.emit(_owner)
		Verbose.debug("Click court (" + str(duration_s).pad_decimals(3) + "s) sur " + _owner.entity_name, Verbose.Category.ENTITY)
		_play_click_marker_animation()
#endregion

#region ============================== Public functions ==============================
func select() -> void:
	_is_selected = true
	_update_selection_marker()


func deselect() -> void:
	_is_selected = false
	_update_selection_marker()
#endregion

#region ============================== Callbacks ==============================
func _on_owner_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton): return
	var mb := event as InputEventMouseButton
	if not mb.pressed: return

	if mb.button_index == MOUSE_BUTTON_RIGHT:
		# Right-click : émission instantanée (pas de timing, le drag est left-only).
		Events.entity_right_clicked.emit(_owner)
		Verbose.debug("Right-click sur " + _owner.entity_name, Verbose.Category.ENTITY)
		return

	if mb.button_index != MOUSE_BUTTON_LEFT: return

	# Left press : démarrer le tracking — l'émission se fera sur release dans _unhandled_input.
	_press_pending = true
	_press_start_msec = Time.get_ticks_msec()
	set_process_unhandled_input(true)


func _on_owner_mouse_entered() -> void:
	_is_hovered = true
	_update_selection_marker()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_owner_mouse_exited() -> void:
	_is_hovered = false
	_update_selection_marker()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
#endregion

#region ============================== Private functions ==============================
func _ensure_selection_marker() -> Node3D:
	if _selection_marker_instance == null:
		_selection_marker_instance = _SELECTION_MARKER_SCENE.instantiate()
		_owner.add_child(_selection_marker_instance)
	return _selection_marker_instance


func _remove_selection_marker() -> void:
	if _selection_marker_instance != null:
		_selection_marker_instance.queue_free()
		_selection_marker_instance = null


func _update_selection_marker() -> void:
	if _is_selected:
		_ensure_selection_marker().show_selected()
	elif _is_hovered:
		_ensure_selection_marker().show_hover()
	else:
		_remove_selection_marker()


func _play_click_marker_animation() -> void:
	_ensure_selection_marker().play_click(_update_selection_marker)
#endregion
