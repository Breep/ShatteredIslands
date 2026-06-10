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
# Team de la spawn zone survolée pendant le drag (1, 2…), ou -1 si hors zone.
signal drop_zone_changed(team: int)
#endregion

#region ============================== Constants ==============================
const LONG_PRESS_THRESHOLD_S: float = 0.2
const DROP_RAY_LENGTH: float = 2.0
const SPAWN_AREA_MASK: int = 4
const CROSS_DECAL_SCENE: PackedScene = preload("res://02_Entities/_Shared/Components/Draggable/cross_decal.tscn")
#endregion

#region ============================== Export ==============================
@export var _drag_height: float = 0.75
@export var _drag_tween_duration: float = 0.15
@export var _drop_tween_duration: float = 0.2
#endregion

#region ============================== Private variables ==============================
var _is_dragging: bool = false
var _ground_y: float = 0.0
var _drag_start_position: Vector3
var _y_tween: Tween

# Tracking du press en attente du seuil long press.
var _press_pending: bool = false
var _press_start_msec: int = 0

# Repérage de la spawn zone survolée (raycast vertical sous l'entité).
var _drop_ray: RayCast3D
var _current_drop_zone: int = -1
var _current_zone_area: Area3D
var _cross_decal: CrossDecal
var _origin_decal: CrossDecal
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
	_update_drop_zone()


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


func get_drop_zone() -> int:
	return _current_drop_zone
#endregion

#region ============================== Private functions ==============================
func _start_drag() -> void:
	if _is_dragging:
		return
	_is_dragging = true
	_ground_y = _owner.global_position.y
	_drag_start_position = _owner.global_position
	Verbose.debug("Drag started on " + _owner.entity_name, Verbose.Category.ENTITY)

	if _owner.movement != null:
		_owner.movement.stop()

	_spawn_drop_ray()
	_spawn_cross_decal()
	_spawn_origin_decal()
	_update_drop_zone()
	_refresh_decal_feedback()
	_kill_y_tween()
	_y_tween = create_tween()
	_y_tween.tween_property(_owner, "global_position:y", _ground_y + _drag_height, _drag_tween_duration)

	set_process(true)
	dragged.emit()
	Events.entity_drag_started.emit(_owner)
	AudioManager.play_3d("whoosh", _owner.position)


func _stop_drag() -> void:
	if not _is_dragging:
		return
	_is_dragging = false
	set_process(false)

	var rollback: bool = _should_rollback()
	_clear_drop_zone()
	Verbose.debug("Drag stopped on " + _owner.entity_name + (" (rollback)" if rollback else ""), Verbose.Category.ENTITY)

	_kill_y_tween()
	_y_tween = create_tween()
	if rollback:
		_y_tween.tween_property(_owner, "global_position", _drag_start_position, _drop_tween_duration)
	else:
		_y_tween.tween_property(_owner, "global_position:y", _ground_y, _drop_tween_duration)

	if _owner.movement != null:
		_owner.movement.start()

	dropped.emit()
	Events.entity_drag_stopped.emit(_owner)
	AudioManager.play_3d("thud", _owner.position)


func _kill_y_tween() -> void:
	if _y_tween != null and _y_tween.is_valid():
		_y_tween.kill()


func _spawn_drop_ray() -> void:
	_drop_ray = RayCast3D.new()
	_drop_ray.target_position = Vector3.DOWN * DROP_RAY_LENGTH
	_drop_ray.collision_mask = SPAWN_AREA_MASK
	_drop_ray.collide_with_areas = true
	_drop_ray.collide_with_bodies = false
	_owner.add_child(_drop_ray)


func _update_drop_zone() -> void:
	if _drop_ray == null:
		return
	_drop_ray.force_raycast_update()
	var area: Area3D = _drop_ray.get_collider() as Area3D if _drop_ray.is_colliding() else null
	if area == _current_zone_area:
		return

	if _current_zone_area != null and _current_zone_area.has_method("set_highlighted"):
		_current_zone_area.set_highlighted(false)
	_current_zone_area = area
	if area != null and area.has_method("set_highlighted"):
		area.set_highlighted(true)

	var team: int = _team_from_collider(area)
	if team != _current_drop_zone:
		_current_drop_zone = team
		drop_zone_changed.emit(team)
	_refresh_decal_feedback()


func _clear_drop_zone() -> void:
	if _current_zone_area != null and _current_zone_area.has_method("set_highlighted"):
		_current_zone_area.set_highlighted(false)
	_current_zone_area = null
	if _current_drop_zone != -1:
		_current_drop_zone = -1
		drop_zone_changed.emit(-1)
	if _drop_ray != null:
		_drop_ray.queue_free()
		_drop_ray = null
	if _cross_decal != null:
		_cross_decal.queue_free()
		_cross_decal = null
	if _origin_decal != null:
		_origin_decal.queue_free()
		_origin_decal = null


func _spawn_cross_decal() -> void:
	_cross_decal = CROSS_DECAL_SCENE.instantiate() as CrossDecal
	_owner.add_child(_cross_decal)


# Marqueur blanc statique à la position de départ (cible du rollback). Posé dans
# le parent de l'entité pour rester fixe pendant que l'entité suit la souris.
func _spawn_origin_decal() -> void:
	var parent: Node = _owner.get_parent()
	if parent == null:
		return
	_origin_decal = CROSS_DECAL_SCENE.instantiate() as CrossDecal
	parent.add_child(_origin_decal)
	_origin_decal.global_position = _drag_start_position
	_origin_decal.stop_pulse()
	_origin_decal.set_neutral()


func _refresh_decal_feedback() -> void:
	if _cross_decal == null:
		return
	if _should_rollback():
		_cross_decal.set_nok()
	else:
		_cross_decal.set_ok()


func _team_from_collider(collider: Object) -> int:
	var node := collider as Node
	if node == null:
		return -1
	for group: StringName in node.get_groups():
		var group_name: String = String(group)
		if group_name.begins_with(SpawnArea.TEAM_GROUP_PREFIX):
			return group_name.substr(SpawnArea.TEAM_GROUP_PREFIX.length()).to_int()
	return -1


# Une entité attachée à une équipe doit finir le drop sur sa propre spawn zone ;
# sinon on la ramène à sa position de départ. Les entités sans équipe sont libres.
func _should_rollback() -> bool:
	Verbose.trace("Team = " + str(_owner.team) + " current_drop_zone = " + str(_current_drop_zone), Verbose.Category.ENTITY_MODULE)
	if _owner.team <= 0:
		return false
	return _current_drop_zone != _owner.team
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
