class_name LevelSelectorPaths
extends Node2D

@export var dash_length: float = 18.0
@export var dash_gap: float = 14.0
@export var dash_color: Color = Color(1, 1, 1, 0.85)
@export var dash_width: float = 5.0
@export var start_pad: float = 110.0
@export var end_pad: float = 110.0

var _segments: Array = []  # Array of [Vector2, Vector2]

func set_segments(segments: Array) -> void:
	_segments = segments
	queue_redraw()

func _draw() -> void:
	for seg in _segments:
		_draw_dashed(seg[0], seg[1])

func _draw_dashed(from_pos: Vector2, to_pos: Vector2) -> void:
	var total: float = from_pos.distance_to(to_pos)
	if total < 0.001:
		return
	var dir: Vector2 = (to_pos - from_pos) / total
	var start_d: float = minf(start_pad, total * 0.5)
	var end_d: float = total - minf(end_pad, total * 0.5)
	if end_d <= start_d:
		return
	var traveled: float = start_d
	while traveled < end_d:
		var seg_end: float = minf(traveled + dash_length, end_d)
		draw_line(from_pos + dir * traveled, from_pos + dir * seg_end, dash_color, dash_width)
		traveled = seg_end + dash_gap
