class_name LevelSelector
extends Control

signal level_launched(path: Array)
signal back_pressed

const ADJACENCY: Dictionary = {
	&"island_1": [&"island_2a", &"island_2b"],
	&"island_2a": [&"island_3a", &"island_3b"],
	&"island_2b": [&"island_3a", &"island_3b"],
	&"island_3a": [&"island_4"],
	&"island_3b": [&"island_4"],
	&"island_4": [],
}

@export var turtle_offset: Vector2 = Vector2(-130, 10)

@onready var _islands_root: Node2D = %IslandsRoot
@onready var _paths_layer: LevelSelectorPaths = %PathsLayer
@onready var _turtle: LevelSelectorTurtle = %Turtle
@onready var _start_button: Button = %StartButton
@onready var _back_button: Button = %BackButton

var _islands_by_id: Dictionary = {}
var _path: Array = [&"island_1"]

func _ready() -> void:
	for child in _islands_root.get_children():
		if child is LevelSelectorIsland:
			var island: LevelSelectorIsland = child
			_islands_by_id[island.island_id] = island
			island.hover_entered.connect(_on_island_hover_entered)
			island.hover_exited.connect(_on_island_hover_exited)
			island.clicked.connect(_on_island_clicked)

	_start_button.pressed.connect(_on_start_pressed)
	_back_button.pressed.connect(_on_back_pressed)

	_paths_layer.set_segments(_build_segments())
	_turtle.snap_to(_turtle_pos_for(&"island_1"))
	_refresh_island_states()
	_refresh_start_button()

func _build_segments() -> Array:
	var segments: Array = []
	for from_id: StringName in ADJACENCY.keys():
		if not _islands_by_id.has(from_id):
			continue
		var from_pos: Vector2 = _islands_by_id[from_id].position
		for to_id: StringName in ADJACENCY[from_id]:
			if not _islands_by_id.has(to_id):
				continue
			var to_pos: Vector2 = _islands_by_id[to_id].position
			segments.append([from_pos, to_pos])
	return segments

func _turtle_pos_for(island_id: StringName) -> Vector2:
	return _islands_by_id[island_id].position + turtle_offset

func _on_island_hover_entered(_island: LevelSelectorIsland) -> void:
	pass

func _on_island_hover_exited(_island: LevelSelectorIsland) -> void:
	pass

func _on_island_clicked(island: LevelSelectorIsland) -> void:
	var clicked_id: StringName = island.island_id
	var clicked_tier: int = island.tier

	if _path.size() > 0 and _path[-1] == clicked_id:
		return
	if clicked_tier > _path.size() + 1:
		return

	var new_path: Array = _path.duplicate()
	if clicked_tier == new_path.size() + 1:
		new_path.append(clicked_id)
	else:
		new_path.resize(clicked_tier - 1)
		new_path.append(clicked_id)

	_route_turtle(_path, new_path)
	_path = new_path
	_refresh_island_states()
	_refresh_start_button()

func _route_turtle(old_path: Array, new_path: Array) -> void:
	var common: int = 0
	var max_common: int = mini(old_path.size(), new_path.size())
	while common < max_common and old_path[common] == new_path[common]:
		common += 1

	var positions: PackedVector2Array = PackedVector2Array()
	var i: int = old_path.size() - 2
	while i >= common - 1 and i >= 0:
		positions.append(_turtle_pos_for(old_path[i]))
		i -= 1
	for j in range(common, new_path.size()):
		positions.append(_turtle_pos_for(new_path[j]))

	_turtle.travel(positions)

func _refresh_island_states() -> void:
	var last_id: StringName = _path[-1] if _path.size() > 0 else StringName()
	var in_path: Dictionary = {}
	for id in _path:
		in_path[id] = true

	for id: StringName in _islands_by_id.keys():
		var island: LevelSelectorIsland = _islands_by_id[id]
		if id == last_id:
			island.set_state(LevelSelectorIsland.State.CURRENT)
		elif in_path.has(id):
			island.set_state(LevelSelectorIsland.State.SELECTED)
		elif island.tier <= _path.size() + 1:
			island.set_state(LevelSelectorIsland.State.REACHABLE)
		else:
			island.set_state(LevelSelectorIsland.State.LOCKED)

func _refresh_start_button() -> void:
	var ready_to_launch: bool = _path.size() >= 2
	_start_button.disabled = not ready_to_launch
	_start_button.modulate.a = 1.0 if ready_to_launch else 0.6

func _on_start_pressed() -> void:
	if _path.size() < 2:
		return
	level_launched.emit(_path.duplicate())
	Verbose.info("LevelSelector: launching path = " + str(_path))

func _on_back_pressed() -> void:
	back_pressed.emit()
	Verbose.info("LevelSelector: back pressed")
