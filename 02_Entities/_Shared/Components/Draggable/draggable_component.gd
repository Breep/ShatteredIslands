class_name DraggableComponent
extends EntityComponent

# Drag déclenché par long press (>= LONG_PRESS_THRESHOLD_S secondes) sur l'entité.
# Avant ce seuil, le press est "pending" — si l'utilisateur release avant, rien
# ne se passe (ClickableComponent émettra son entity_clicked si <0.1s).
# Spatial motion (Y elevation, XZ following) lives here ; visual pose updates
# are the AnimationComponent's job — il réagit aux signals dragged/dropped.

#region ============================== Signals ==============================
signal dragged()
signal dropped()
#endregion

#region ============================== Constants ==============================
const LONG_PRESS_THRESHOLD_S: float = 0.2
#endregion

#region ============================== Export ==============================
@export var _drag_height: float = 0.75
@export var _drag_tween_duration: float = 0.15
@export var _drop_tween_duration: float = 0.2
#endregion

#region ============================== Private variables ==============================
var _is_dragging: bool = false
var _ground_y: float = 0.0
var _y_tween: Tween

# Tracking du press en attente du seuil long press.
var _press_pending: bool = false
var _press_start_msec: int = 0
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
	# Pendant un press en attente : check si on a atteint le seuil long press → start drag.
	if _press_pending and not _is_dragging:
		var duration_s: float = float(Time.get_ticks_msec() - _press_start_msec) / 1000.0
		if duration_s >= LONG_PRESS_THRESHOLD_S:
			_press_pending = false
			_start_drag()
		return # Pendant pending, on ne fait pas encore le suivi de souris

	# Pendant drag actif : suivi XZ de la souris.
	if not _is_dragging: return
	var viewport: Viewport = _owner.get_viewport()
	if viewport == null: return
	var camera: Camera3D = viewport.get_camera_3d()
	if camera == null: return

	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var plane := Plane(Vector3.UP, _ground_y)
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)
	var hit: Variant = plane.intersects_ray(from, dir)
	if hit == null: return
	_owner.global_position.x = hit.x
	_owner.global_position.z = hit.z


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton): return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or mb.pressed: return

	# Release left button : si on draggait, on stoppe. Si pending, on annule.
	if _is_dragging:
		_stop_drag()
	elif _press_pending:
		_press_pending = false
		set_process(false)
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
	Verbose.debug("Drag started on " + _owner.entity_name, Verbose.Category.ENTITY)

	if _owner.movement != null:
		_owner.movement.stop()

	_kill_y_tween()
	_y_tween = create_tween()
	_y_tween.tween_property(_owner, "global_position:y", _ground_y + _drag_height, _drag_tween_duration)

	set_process(true)
	dragged.emit()
	AudioManager.play_3d("whoosh", _owner.position)


func _stop_drag() -> void:
	if not _is_dragging:
		return
	_is_dragging = false
	set_process(false)
	Verbose.debug("Drag stopped on " + _owner.entity_name, Verbose.Category.ENTITY)

	_kill_y_tween()
	_y_tween = create_tween()
	_y_tween.tween_property(_owner, "global_position:y", _ground_y, _drop_tween_duration)

	if _owner.movement != null:
		_owner.movement.start()

	dropped.emit()
	AudioManager.play_3d("thud", _owner.position)


func _kill_y_tween() -> void:
	if _y_tween != null and _y_tween.is_valid():
		_y_tween.kill()
#endregion

#region ============================== Callbacks ==============================
func _on_owner_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton): return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed: return

	# Démarrer le tracking du press. Le drag ne démarre que si on dépasse le seuil
	# (vérifié dans _process). set_process(true) pour pouvoir mesurer le temps écoulé.
	_press_pending = true
	_press_start_msec = Time.get_ticks_msec()
	set_process(true)
#endregion
