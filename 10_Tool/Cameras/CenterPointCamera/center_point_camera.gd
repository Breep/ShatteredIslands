class_name CenterPointCamera
extends Node3D

# ============================== Enums ==============================

enum Distance { CLOSE, MIDDLE, FAR, VERY_FAR, DRAGON_FLIGHT }
enum Transition { TWEEN, LERP, INSTANT }

# ============================== Local node ==============================

#@export var _clicker_module: ClickerModule

# ============================== Configuration ==============================

@export var _rotation_sensitivity: float = 0.3
@export var _zoom_sensitivity: float = 1.0

@export var _zoom_min: float = 10.0
@export var _zoom_max: float = 40.0

# ============================== Distances ==============================

@export_group("Distances")
@export var _close_position: Vector3 = Vector3(35, 0, 0)
@export var _close_rotation: Vector3 = Vector3(0, 90, 40)
@export var _middle_position: Vector3 = Vector3(47.5, 0, 0)
@export var _middle_rotation: Vector3 = Vector3(0, 90, 50)
@export var _far_position: Vector3 = Vector3(60, 0, 0)
@export var _far_rotation: Vector3 = Vector3(0, 90, 60)
@export var _very_far_position: Vector3 = Vector3(72.5, 0, 0)
@export var _very_far_rotation: Vector3 = Vector3(0, 90, 70)
## Cinematic framing for the dragon's flight: pulled out, and flatter than the others so the
## arena reads more side-on and the dragon sits near the horizon (same euler convention as the
## presets above — tune in the inspector to taste).
@export var _dragon_flight_position: Vector3 = Vector3(45, 0, 0)
@export var _dragon_flight_rotation: Vector3 = Vector3(0, 90, 20)
## Head-tilt for the dragon view: pitches the camera itself up in place (degrees, + = looks
## higher, toward the dragon / sky), on top of the neutral aim. Undone on restore.
@export var _dragon_flight_camera_tilt: float = 7.0

@export var _intro_duration: float = 4.0
@export var _lerp_speed: float = 5.0

# ============================== Control ==============================

@export_group("Control")
@export var _locked: bool = false

# ============================== Free fly ==============================

@export_group("Free fly")
@export var _free_fly_move_speed: float = 25.0
@export var _free_fly_look_sensitivity: float = 0.2


@onready var _camera: Camera3D = %Camera3D
@onready var _center_point: Node3D = %CenterPoint

# ============================== Private variables ==============================

# The locally-current camera, exposed so presentation code (e.g. the dragon flight zoom)
# can drive whichever camera the local player is looking through, without coupling to the
# island that owns it. Maintained by set_active() / set_inactive().
static var _active: CenterPointCamera

var _is_active: bool = false
var _rotating := false
var _free_fly: bool = false
var _camera_local_transform: Transform3D
var _lerping: bool = false
var _lerp_target_position: Vector3
var _lerp_target_rotation: Vector3

# Snapshot + tween for push_distance() / restore() — event framings (e.g. the dragon flight)
# that ease to a preset and later hand the camera back exactly as they found it.
var _has_pushed_pose: bool = false
var _pushed_position: Vector3
var _pushed_center_rotation: Vector3
var _pushed_camera_rotation: Vector3
var _event_tween: Tween

# ============================== Node base functions ==============================

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active: return
	_handle_free_fly_toggle(event)
	if _free_fly:
		_handle_free_fly_look(event)
		return
	_handle_distance_shortcut(event)
	if _locked: return
	_handle_center_point_rotation(event)
	_handle_camera_zoom(event)


func _process(delta: float) -> void:
	if _free_fly:
		_handle_free_fly_move(delta)
		return
	if _lerping:
		_handle_distance_lerp(delta)

# ============================== Public functions ==============================

static func active() -> CenterPointCamera:
	return _active


func set_active() -> void:
	if _is_active: return
	_is_active = true
	_active = self
	_camera.make_current()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	if _active == self:
		_active = null


func play_intro() -> void:
	go_to(Distance.FAR, Transition.INSTANT)
	go_to(Distance.CLOSE, Transition.TWEEN)


func go_to(distance: Distance, transition: Transition = Transition.TWEEN) -> void:
	var pose: Array = _pose_for(distance)
	var target_position: Vector3 = pose[0]
	var target_rotation: Vector3 = pose[1]
	match transition:
		Transition.TWEEN:
			_lerping = false
			_tween_to(target_position, target_rotation)
		Transition.LERP:
			_lerp_target_position = target_position
			_lerp_target_rotation = target_rotation
			_lerping = true
		Transition.INSTANT:
			_lerping = false
			_camera.position = target_position
			_center_point.rotation_degrees = target_rotation


## Snapshot the current framing, ease to `distance`'s preset (position + angle), and let a later
## restore() return to that snapshot — for event framings (e.g. the dragon's flight) that must
## hand the camera back exactly as they found it. `duration` is the eased travel time (seconds).
func push_distance(distance: Distance, duration: float) -> void:
	_pushed_position = _camera.position
	_pushed_center_rotation = _center_point.rotation_degrees
	_pushed_camera_rotation = _camera.rotation_degrees
	_has_pushed_pose = true
	var pose: Array = _pose_for(distance)
	var target_camera_rotation: Vector3 = _pushed_camera_rotation
	target_camera_rotation.x += pose[2] # head tilt (degrees) over the neutral aim, 0 for plain presets
	_tween_event(pose[0], pose[1], target_camera_rotation, duration)


func restore(duration: float) -> void:
	if not _has_pushed_pose: return
	_has_pushed_pose = false
	_tween_event(_pushed_position, _pushed_center_rotation, _pushed_camera_rotation, duration)

# ============================== Private functions ==============================

func _tween_event(target_position: Vector3, target_center_rotation: Vector3, target_camera_rotation: Vector3, duration: float) -> void:
	if _event_tween != null and _event_tween.is_valid():
		_event_tween.kill()
	_lerping = false # don't let a pending distance-lerp fight the event framing
	_event_tween = create_tween().set_parallel(true)
	_event_tween.tween_property(_camera, "position", target_position, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_event_tween.tween_property(_center_point, "rotation_degrees", target_center_rotation, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_event_tween.tween_property(_camera, "rotation_degrees", target_camera_rotation, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# pose[2] = camera head-tilt in degrees (event framings only); plain presets carry 0.
func _pose_for(distance: Distance) -> Array:
	match distance:
		Distance.MIDDLE: return [_middle_position, _middle_rotation, 0.0]
		Distance.FAR: return [_far_position, _far_rotation, 0.0]
		Distance.VERY_FAR: return [_very_far_position, _very_far_rotation, 0.0]
		Distance.DRAGON_FLIGHT: return [_dragon_flight_position, _dragon_flight_rotation, _dragon_flight_camera_tilt]
		_: return [_close_position, _close_rotation, 0.0]


func _tween_to(target_position: Vector3, target_rotation: Vector3) -> Tween:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_camera, "position", target_position, _intro_duration)
	tween.tween_property(_center_point, "rotation_degrees", target_rotation, _intro_duration)
	return tween


func _handle_distance_lerp(delta: float) -> void:
	var weight: float = clampf(_lerp_speed * delta, 0.0, 1.0)
	_camera.position = _camera.position.lerp(_lerp_target_position, weight)
	_center_point.rotation_degrees = _center_point.rotation_degrees.lerp(_lerp_target_rotation, weight)
	if _camera.position.distance_to(_lerp_target_position) < 0.01 \
			and _center_point.rotation_degrees.distance_to(_lerp_target_rotation) < 0.01:
		_camera.position = _lerp_target_position
		_center_point.rotation_degrees = _lerp_target_rotation
		_lerping = false


# Alt+1..4 vont aux distances CLOSE / MIDDLE / FAR / VERY_FAR.
func _handle_distance_shortcut(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo and event.alt_pressed): return
	match event.keycode:
		KEY_1: go_to(Distance.CLOSE, Transition.LERP)
		KEY_2: go_to(Distance.MIDDLE, Transition.LERP)
		KEY_3: go_to(Distance.FAR, Transition.LERP)
		KEY_4: go_to(Distance.VERY_FAR, Transition.LERP)


# Alt+C bascule le mode caméra libre (free fly).
func _handle_free_fly_toggle(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo): return
	if event.keycode != KEY_C or not event.alt_pressed: return
	if _free_fly:
		_exit_free_fly()
	else:
		_enter_free_fly()


# La caméra passe en top level : sa transform locale devient sa transform
# globale, donc les contrôles free fly (basis locale = globale) sont identiques
# à FreeFlyCamera, sans interférence du rig orbital.
func _enter_free_fly() -> void:
	_free_fly = true
	_lerping = false
	_camera_local_transform = _camera.transform
	var keep: Transform3D = _camera.global_transform
	_camera.set_as_top_level(true)
	_camera.global_transform = keep
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _exit_free_fly() -> void:
	_free_fly = false
	_camera.set_as_top_level(false)
	_camera.transform = _camera_local_transform
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _handle_free_fly_look(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera.rotate_y(deg_to_rad(-event.relative.x * _free_fly_look_sensitivity))
		var new_pitch: float = _camera.rotation_degrees.x - event.relative.y * _free_fly_look_sensitivity
		_camera.rotation_degrees.x = clamp(new_pitch, -89, 89)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_exit_free_fly()


func _handle_free_fly_move(delta: float) -> void:
	var velocity: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		velocity -= _camera.transform.basis.z
	if Input.is_action_pressed("move_backward"):
		velocity += _camera.transform.basis.z
	if Input.is_action_pressed("move_left"):
		velocity -= _camera.transform.basis.x
	if Input.is_action_pressed("move_right"):
		velocity += _camera.transform.basis.x
	if Input.is_action_pressed("move_up"):
		velocity += _camera.transform.basis.y
	if Input.is_action_pressed("move_down"):
		velocity -= _camera.transform.basis.y
	_camera.global_transform.origin += velocity.normalized() * _free_fly_move_speed * delta


func _handle_center_point_rotation(event: InputEvent) -> void:
	if event.is_action_pressed("camera_rotate"):
		_rotating = true
	elif event.is_action_released("camera_rotate"):
		_rotating = false

	if _rotating:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and _rotating:
		var delta = event.relative
		rotate_y(deg_to_rad(-delta.x * _rotation_sensitivity))
		var x_rotation = delta.y * _rotation_sensitivity
		var new_rotation = rotation_degrees.x + x_rotation
		# Clamp the vertical rotation to avoid flipping
		new_rotation = clamp(new_rotation, -80, 80)
		rotation_degrees.x = new_rotation


func _handle_camera_zoom(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		_camera.position.x -= _zoom_sensitivity
	elif event.is_action_pressed("camera_zoom_out"):
		_camera.position.x += _zoom_sensitivity
	_camera.position.x = clampf(_camera.position.x, _zoom_min, _zoom_max)
