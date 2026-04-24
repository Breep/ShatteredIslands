class_name LevelSelectorTurtle
extends Node2D

signal arrived

@export var travel_speed: float = 700.0
@export var bob_amplitude: float = 4.0
@export var bob_period: float = 0.9

@onready var _body: Node2D = %Body
@onready var _shell: Polygon2D = %Shell
@onready var _head: Polygon2D = %Head
@onready var _leg_fl: Polygon2D = %LegFL
@onready var _leg_fr: Polygon2D = %LegFR
@onready var _leg_bl: Polygon2D = %LegBL
@onready var _leg_br: Polygon2D = %LegBR

var _travel_tween: Tween
var _bob_time: float = 0.0
var _is_walking: bool = false

func _ready() -> void:
	_shell.polygon = _ellipse(28.0, 22.0, 28)
	_shell.color = Color(0.35, 0.55, 0.28)
	_head.polygon = _ellipse(10.0, 8.0, 20)
	_head.color = Color(0.55, 0.75, 0.42)
	_head.position = Vector2(28.0, 0.0)

	var leg_shape := _ellipse(7.0, 5.0, 16)
	_leg_fl.polygon = leg_shape
	_leg_fr.polygon = leg_shape
	_leg_bl.polygon = leg_shape
	_leg_br.polygon = leg_shape
	for leg in [_leg_fl, _leg_fr, _leg_bl, _leg_br]:
		leg.color = Color(0.45, 0.65, 0.35)
	_leg_fl.position = Vector2(18.0, -18.0)
	_leg_fr.position = Vector2(18.0, 18.0)
	_leg_bl.position = Vector2(-18.0, -18.0)
	_leg_br.position = Vector2(-18.0, 18.0)

func _process(delta: float) -> void:
	_bob_time += delta
	var bob := sin(_bob_time * TAU / bob_period) * bob_amplitude
	_body.position.y = bob
	if _is_walking:
		var wiggle := sin(_bob_time * TAU / (bob_period * 0.5)) * 6.0
		_leg_fl.position.x = 18.0 + wiggle
		_leg_br.position.x = -18.0 + wiggle
		_leg_fr.position.x = 18.0 - wiggle
		_leg_bl.position.x = -18.0 - wiggle
	else:
		_leg_fl.position.x = 18.0
		_leg_fr.position.x = 18.0
		_leg_bl.position.x = -18.0
		_leg_br.position.x = -18.0

static func _ellipse(rx: float, ry: float, segments: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var angle := TAU * float(i) / float(segments)
		pts.append(Vector2(cos(angle) * rx, sin(angle) * ry))
	return pts

func snap_to(pos: Vector2) -> void:
	if _travel_tween:
		_travel_tween.kill()
		_travel_tween = null
	_is_walking = false
	global_position = pos

func travel(points: PackedVector2Array) -> void:
	if _travel_tween:
		_travel_tween.kill()
		_travel_tween = null

	if points.is_empty():
		arrived.emit()
		return

	_is_walking = true
	_travel_tween = create_tween()
	var previous: Vector2 = global_position
	for p in points:
		var dist: float = previous.distance_to(p)
		var duration: float = maxf(0.08, dist / travel_speed)
		var from_point: Vector2 = previous
		_travel_tween.tween_callback(_face_toward.bind(from_point, p))
		_travel_tween.tween_property(self, "global_position", p, duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		previous = p
	_travel_tween.finished.connect(_on_travel_finished)

func _face_toward(from_point: Vector2, to_point: Vector2) -> void:
	var delta: Vector2 = to_point - from_point
	if delta.length_squared() < 0.0001:
		return
	_body.rotation = delta.angle()

func _on_travel_finished() -> void:
	_is_walking = false
	arrived.emit()
