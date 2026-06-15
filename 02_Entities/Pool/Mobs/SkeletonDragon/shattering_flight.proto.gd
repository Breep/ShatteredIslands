class_name ShatteringFlightPathProto
extends Node3D

# Proto: authors and validates the Skeleton Dragon "Vol fracassant" flight PATH in
# isolation. Builds the curve from a FlightPathProfile, draws it (line + banking hairs),
# and flies a proxy dragon along it with tangent facing + banking, so the cinematic feel
# and the 4–5 s timing can be tuned before wiring it into the real ShatteringFlightAbility.
# Banking is computed here (consumer side) from the path's horizontal turn direction, on a
# twist-free frame — never from the curve's baked up-vector, whose parallel-transport flips
# would invert the lean mid-loop. Runs on frame time, not the combat tick clock, on purpose.

#region Enums
enum State { GROUNDED, FLYING }
#endregion

#region Export
@export var _profile: FlightPathProfile
@export var _flight_duration: float = 5.0
## Fraction of the flight spent easing in/out at each end (0 = constant speed).
@export_range(0.0, 0.5, 0.01) var _ease_edge: float = 0.2

@export_group("Banking")
## Lean angle into turns (degrees). 0 = stays flat.
@export_range(0.0, 80.0, 1.0) var _bank_degrees: float = 40.0
## Reverse the lean partway through the flight (the dragon rolls level, then the other way).
@export var _bank_flip: bool = false
## Where the flip happens, as a fraction of the flight [0..1].
@export_range(0.0, 1.0, 0.01) var _bank_flip_at: float = 0.5
## Half-width of the smooth roll-through-level transition around the flip point.
@export_range(0.01, 0.3, 0.01) var _bank_flip_width: float = 0.08
#endregion

#region Private vars
const _FACING_LOOKAHEAD: float = 1.0
const _ANIM_FLY_IDLE: String = "Fly_Idle"
const _ANIM_GROUND_IDLE: String = "Idle_Ground"

@onready var _flyer: Node3D = %Flyer
@onready var _path_draw: MeshInstance3D = %PathDraw
@onready var _camera: Camera3D = $Camera3D
@onready var _status: Label = %StatusLabel
@onready var _anim: AnimationPlayer = $Flyer/SkeletalDragonVisual/AnimationPlayer

var _curve: Curve3D
var _state: State = State.GROUNDED
var _elapsed: float = 0.0
var _saved_bank: float = 40.0
#endregion

#region Node base functions
func _ready() -> void:
	if _profile == null:
		_profile = FlightPathProfile.new()
	_camera.look_at(Vector3(2.0, 3.0, -4.0))

	%TakeOffButton.pressed.connect(_take_off)
	%ResetButton.pressed.connect(_reset_ground)
	%RebuildButton.pressed.connect(_rebuild)
	%BankButton.pressed.connect(_toggle_bank)
	%TiltButton.pressed.connect(_cycle_tilt)
	%FlipButton.pressed.connect(_toggle_flip)

	_saved_bank = _bank_degrees
	_rebuild()
	_reset_ground()


func _process(delta: float) -> void:
	if _state != State.FLYING or _curve == null:
		return
	_elapsed += delta
	var ratio: float = clampf(_elapsed / maxf(0.01, _flight_duration), 0.0, 1.0)
	_place_flyer_at(_eased(ratio))
	if ratio >= 1.0:
		_reset_ground()
#endregion

#region Private functions
func _take_off() -> void:
	if _state == State.FLYING:
		_elapsed = 0.0  # replay
		return
	_state = State.FLYING
	_elapsed = 0.0
	_anim.play(_ANIM_FLY_IDLE, 0.2)
	_update_status()


func _reset_ground() -> void:
	_state = State.GROUNDED
	_flyer.transform = Transform3D(Basis(), Vector3.ZERO)
	if _anim.has_animation(_ANIM_GROUND_IDLE):
		_anim.play(_ANIM_GROUND_IDLE, 0.2)
	_update_status()


func _rebuild() -> void:
	_curve = _profile.build_curve()
	_redraw_path()
	_update_status()


func _toggle_bank() -> void:
	if _bank_degrees != 0.0:
		_saved_bank = _bank_degrees
		_bank_degrees = 0.0
	else:
		_bank_degrees = _saved_bank
	_redraw_path()
	_update_status()


func _toggle_flip() -> void:
	_bank_flip = not _bank_flip
	_redraw_path()
	_update_status()


func _cycle_tilt() -> void:
	var steps: Array[float] = [0.0, 0.33, 0.66, 1.0]
	var next: float = steps[0]
	for s: float in steps:
		if s > _profile.disc_tilt + 0.01:
			next = s
			break
	_profile.disc_tilt = next
	_rebuild()


func _place_flyer_at(arc_ratio: float) -> void:
	var length: float = _curve.get_baked_length()
	if length <= 0.0:
		return
	_flyer.transform = _sample_frame(arc_ratio * length, length)


# Full pose along the curve: -Z = travel tangent (nose pitches with climbs/dives), and the
# up vector is a twist-free level frame rolled by the banking angle.
func _sample_frame(dist: float, length: float) -> Transform3D:
	var pos: Vector3 = _curve.sample_baked(dist)
	var ahead: Vector3 = _curve.sample_baked(minf(dist + _FACING_LOOKAHEAD, length))
	var fwd: Vector3 = ahead - pos
	if fwd.length_squared() < 0.0001:
		fwd = -_flyer.global_transform.basis.z
	fwd = fwd.normalized()
	return Transform3D(Basis(), pos).looking_at(pos + fwd, _banked_up(fwd, pos, dist, length))


# A level up-vector (perpendicular to travel, no parallel-transport twist) rolled around
# the travel axis by the banking angle.
func _banked_up(fwd: Vector3, pos: Vector3, dist: float, length: float) -> Vector3:
	var right: Vector3 = fwd.cross(Vector3.UP)
	if right.length_squared() < 0.00001:  # travelling near-vertical
		right = fwd.cross(Vector3.FORWARD)
	right = right.normalized()
	var level_up: Vector3 = right.cross(fwd).normalized()
	return level_up.rotated(fwd, _roll_angle(pos, dist, length))


# Roll from the signed horizontal turn direction → constant lean on a constant-radius
# loop. The flip multiplier reverses it (smoothly, through level) past _bank_flip_at.
func _roll_angle(pos: Vector3, dist: float, length: float) -> float:
	var e: float = 0.5
	var back: Vector3 = _curve.sample_baked(clampf(dist - e, 0.0, length))
	var front: Vector3 = _curve.sample_baked(clampf(dist + e, 0.0, length))
	var hb: Vector2 = Vector2(pos.x - back.x, pos.z - back.z)
	var hf: Vector2 = Vector2(front.x - pos.x, front.z - pos.z)
	if hb.length_squared() < 0.000001 or hf.length_squared() < 0.000001:
		return 0.0
	return -signf(hb.angle_to(hf)) * deg_to_rad(_bank_degrees) * _flip_sign(dist / length)


# +1 before the flip, -1 after, ramping smoothly through 0 across the flip window.
func _flip_sign(r: float) -> float:
	if not _bank_flip:
		return 1.0
	var w: float = maxf(0.001, _bank_flip_width)
	return 1.0 - 2.0 * smoothstep(_bank_flip_at - w, _bank_flip_at + w, r)


# Ease in/out only near the extremities, constant speed through the middle — reads as a
# committed cruise rather than the global smoothstep's slow-fast-slow over the whole arc.
func _eased(r: float) -> float:
	var e: float = _ease_edge
	if e <= 0.0:
		return r
	if r < e:
		return smoothstep(0.0, 1.0, r / e) * e
	if r > 1.0 - e:
		return (1.0 - e) + smoothstep(0.0, 1.0, (r - (1.0 - e)) / e) * e
	return r


func _redraw_path() -> void:
	var mesh: ImmediateMesh = _path_draw.mesh as ImmediateMesh
	if mesh == null:
		mesh = ImmediateMesh.new()
		_path_draw.mesh = mesh
		_path_draw.material_override = _line_material()
	mesh.clear_surfaces()
	if _curve == null or _curve.get_baked_length() <= 0.0:
		return
	var length: float = _curve.get_baked_length()

	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	var line_steps: int = 96
	for i in line_steps + 1:
		mesh.surface_set_color(Color(0.2, 0.8, 1.0))
		mesh.surface_add_vertex(_curve.sample_baked(length * float(i) / float(line_steps)))
	mesh.surface_end()

	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	var hair_steps: int = 24
	for i in hair_steps + 1:
		var d: float = length * float(i) / float(hair_steps)
		var frame: Transform3D = _sample_frame(d, length)
		mesh.surface_set_color(Color(1.0, 0.55, 0.1, 0.9))
		mesh.surface_add_vertex(frame.origin)
		mesh.surface_set_color(Color(1.0, 0.55, 0.1, 0.1))
		mesh.surface_add_vertex(frame.origin + frame.basis.y * 1.2)
	mesh.surface_end()


func _line_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.vertex_color_use_as_albedo = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


func _update_status() -> void:
	var length: float = 0.0 if _curve == null else _curve.get_baked_length()
	var flip_txt: String = ("@%d%%" % int(round(_bank_flip_at * 100.0))) if _bank_flip else "off"
	_status.text = "R %.0f  H %.0f  Laps %d  Tilt %.2f\nBank %.0f°  Flip %s   Len %.1f m  Dur %.1f s  %s" % [
		_profile.radius, _profile.height, _profile.laps, _profile.disc_tilt,
		_bank_degrees, flip_txt, length, _flight_duration, State.keys()[_state]]
#endregion
