class_name ClickableComponent
extends EntityComponent

# Handles click and hover interaction for an entity:
# - Mouse hover toggles the selection marker (hover state) and the cursor shape
# - Left click broadcasts Events.entity_clicked and plays the marker animation
# - select()/deselect() drive the marker selected state from external code

#region ============================== Constants ==============================
const _SELECTION_MARKER_SCENE: PackedScene = preload("res://02_Entities/_Shared/Misc/selection_marker.tscn")
#endregion

#region ============================== Private variables ==============================
var _selection_marker_instance: Node3D = null
var _is_selected: bool = false
var _is_hovered: bool = false
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	if _owner == null:
		return
	_owner.input_event.connect(_on_owner_input_event)
	_owner.mouse_entered.connect(_on_owner_mouse_entered)
	_owner.mouse_exited.connect(_on_owner_mouse_exited)
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
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Events.entity_clicked.emit(_owner)
			Verbose.debug("L'entité " + _owner.entity_name + " a été cliquée !", Verbose.Category.ENTITY)
			_play_click_marker_animation()


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
