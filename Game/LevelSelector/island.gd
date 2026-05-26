class_name LevelSelectorIsland
extends Node2D

signal hover_entered(island: LevelSelectorIsland)
signal hover_exited(island: LevelSelectorIsland)
signal clicked(island: LevelSelectorIsland)

enum State { LOCKED, REACHABLE, SELECTED, CURRENT }

@export var island_id: StringName = &""
@export var tier: int = 1
@export var display_title: String = "NIVEAU"
@export var display_subtitle: String = ""
@export var hover_scale: float = 1.12
@export var radius: float = 90.0
@export var body_color: Color = Color(0.42, 0.72, 0.45)

@onready var _visual: Node2D = %Visual
@onready var _body: Polygon2D = %Body
@onready var _outline: Line2D = %Outline
@onready var _lock_icon: Node2D = %LockIcon
@onready var _selection_ring: Line2D = %SelectionRing
@onready var _current_halo: Polygon2D = %CurrentHalo
@onready var _title_label: Label = %TitleLabel
@onready var _subtitle_label: Label = %SubtitleLabel
@onready var _area: Area2D = %Area2D
@onready var _collision: CollisionShape2D = %CollisionShape2D

var _state: State = State.LOCKED
var _hover_tween: Tween
var _ring_tween: Tween
var _halo_tween: Tween

func _ready() -> void:
	_build_visual()
	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_area.input_event.connect(_on_input_event)
	set_state(State.LOCKED)

func _build_visual() -> void:
	var pts := _make_circle_points(radius, 32)
	_body.polygon = pts
	_body.color = body_color

	_outline.points = _closed_loop(pts)
	_outline.width = 4.0
	_outline.default_color = Color(0.15, 0.3, 0.2, 0.6)

	_selection_ring.points = _closed_loop(_make_circle_points(radius + 14.0, 40))
	_selection_ring.width = 6.0
	_selection_ring.default_color = Color(1.0, 0.85, 0.25)
	_selection_ring.visible = false

	_current_halo.polygon = _make_circle_points(radius + 28.0, 40)
	_current_halo.color = Color(0.25, 0.85, 1.0, 0.25)
	_current_halo.visible = false

	var shape := CircleShape2D.new()
	shape.radius = radius
	_collision.shape = shape

	_title_label.text = display_title
	_subtitle_label.text = display_subtitle

static func _make_circle_points(r: float, segments: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var angle := TAU * float(i) / float(segments)
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	return pts

static func _closed_loop(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array(pts)
	if out.size() > 0:
		out.append(out[0])
	return out

func set_state(new_state: State) -> void:
	_state = new_state
	_selection_ring.visible = new_state == State.SELECTED
	_current_halo.visible = new_state == State.CURRENT
	_lock_icon.visible = new_state == State.LOCKED

	match new_state:
		State.LOCKED:
			modulate = Color(0.65, 0.65, 0.7, 1.0)
			_area.input_pickable = false
		State.REACHABLE:
			modulate = Color.WHITE
			_area.input_pickable = true
		State.SELECTED:
			modulate = Color.WHITE
			_area.input_pickable = true
			_pulse_selection_ring()
		State.CURRENT:
			modulate = Color.WHITE
			_area.input_pickable = true
			_pulse_current_halo()

func get_state() -> State:
	return _state

func _pulse_selection_ring() -> void:
	if _ring_tween:
		_ring_tween.kill()
	_selection_ring.scale = Vector2.ONE
	_ring_tween = create_tween().set_loops()
	_ring_tween.tween_property(_selection_ring, "scale", Vector2.ONE * 1.08, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_ring_tween.tween_property(_selection_ring, "scale", Vector2.ONE, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _pulse_current_halo() -> void:
	if _halo_tween:
		_halo_tween.kill()
	_current_halo.modulate.a = 0.8
	_halo_tween = create_tween().set_loops()
	_halo_tween.tween_property(_current_halo, "modulate:a", 0.4, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_halo_tween.tween_property(_current_halo, "modulate:a", 0.8, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_mouse_entered() -> void:
	if _state == State.LOCKED:
		return
	hover_entered.emit(self)
	_tween_scale(hover_scale)

func _on_mouse_exited() -> void:
	if _state == State.LOCKED:
		return
	hover_exited.emit(self)
	_tween_scale(1.0)

func _tween_scale(target: float) -> void:
	if _hover_tween:
		_hover_tween.kill()
	_hover_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(_visual, "scale", Vector2.ONE * target, 0.2)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _state == State.LOCKED:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self)
