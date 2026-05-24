class_name DraggableComponent
extends EntityComponent

# Handles drag interaction on an entity:
# - Press on entity → starts a drag session (tween Y up, follow mouse on XZ plane)
# - Release anywhere → ends the session (tween Y down)
# Spatial motion (Y elevation, XZ following) lives here; visual pose updates are
# the AnimationComponent's job — it reacts to the dragged/dropped signals.

#region ============================== Signals ==============================
signal dragged()
signal dropped()
#endregion

#region ============================== Export ==============================
@export var _drag_height: float = 1.5
@export var _drag_tween_duration: float = 0.15
@export var _drop_tween_duration: float = 0.2
#endregion

#region ============================== Private variables ==============================
var _is_dragging: bool = false
var _ground_y: float = 0.0
var _y_tween: Tween
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if _owner == null: return
	if _owner.draggable != null and _owner.draggable != self:
		Verbose.trace("Override: DraggableComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.draggable.queue_free()
	_owner.draggable = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.draggable != self:
		return
	_owner.input_event.connect(_on_owner_input_event)
	set_process(false)


func _process(_delta: float) -> void:
	var viewport: Viewport = _owner.get_viewport()
	if viewport == null:
		return
	var camera: Camera3D = viewport.get_camera_3d()
	if camera == null:
		return

	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var plane := Plane(Vector3.UP, _ground_y)
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)
	var hit: Variant = plane.intersects_ray(from, dir)
	if hit == null:
		return
	_owner.global_position.x = hit.x
	_owner.global_position.z = hit.z


func _unhandled_input(event: InputEvent) -> void:
	if not _is_dragging:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_stop_drag()
#endregion

#region ============================== Public functions ==============================
func is_dragging() -> bool:
	return _is_dragging
#endregion

#region ============================== Private functions ==============================
func _start_drag() -> void:
	if _is_dragging:
		return
	_is_dragging = true
	_ground_y = _owner.global_position.y
	Verbose.debug("Drag started", Verbose.Category.ENTITY)

	if _owner.movement != null:
		_owner.movement.stop()

	_kill_y_tween()
	_y_tween = create_tween()
	_y_tween.tween_property(_owner, "global_position:y", _ground_y + _drag_height, _drag_tween_duration)

	set_process(true)
	dragged.emit()


func _stop_drag() -> void:
	if not _is_dragging:
		return
	_is_dragging = false
	set_process(false)
	Verbose.debug("Drag stopped", Verbose.Category.ENTITY)

	_kill_y_tween()
	_y_tween = create_tween()
	_y_tween.tween_property(_owner, "global_position:y", _ground_y, _drop_tween_duration)

	if _owner.movement != null:
		_owner.movement.start()

	dropped.emit()


func _kill_y_tween() -> void:
	if _y_tween != null and _y_tween.is_valid():
		_y_tween.kill()
#endregion

#region ============================== Callbacks ==============================
func _on_owner_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_drag()
#endregion
