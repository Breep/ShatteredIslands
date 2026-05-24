# Proto: génère et affiche un arbre radial procédural pour valider l'algo
# de MapTreeGenerator avant intégration au LevelSelector.
extends Control

#region Constants
const ISLAND_SCENE: PackedScene = preload("res://Game/LevelSelector/island.tscn")
const INVALID_NODE_TINT: Color = Color(1.0, 0.35, 0.35, 1.0)
const PANEL_WIDTH: float = 290.0
const ZOOM_STEP: float = 0.1
#endregion


#region Private vars
var _last_graph: MapTreeGenerator.Graph
var _level_target_spinboxes: Array = []
var _is_panning: bool = false
#endregion


#region Onready
@onready var _world_viewport: Control = %WorldViewport
@onready var _world: Node2D = %World
@onready var _islands_root: Node2D = %IslandsRoot
@onready var _paths: LevelSelectorPaths = %PathsLayer

@onready var _seed_field: LineEdit = %SeedField
@onready var _total_nodes: SpinBox = %TotalNodes
@onready var _level_count: SpinBox = %LevelCount
@onready var _root_branches: SpinBox = %RootBranches
@onready var _min_children: SpinBox = %MinChildren
@onready var _max_children: SpinBox = %MaxChildren
@onready var _ring_spacing: SpinBox = %RingSpacing
@onready var _decay_exponent: HSlider = %DecayExponent
@onready var _decay_exponent_label: Label = %DecayExponentLabel
@onready var _level_targets_grid: GridContainer = %LevelTargetsGrid
@onready var _auto_fill_targets_btn: Button = %AutoFillTargetsBtn
@onready var _angular_jitter: HSlider = %AngularJitter
@onready var _angular_jitter_label: Label = %AngularJitterLabel
@onready var _radial_jitter: SpinBox = %RadialJitter
@onready var _min_angular_gap: SpinBox = %MinAngularGap
@onready var _min_node_distance: SpinBox = %MinNodeDistance
@onready var _zoom_slider: HSlider = %ZoomSlider
@onready var _zoom_label: Label = %ZoomLabel
@onready var _regenerate_btn: Button = %RegenerateBtn
@onready var _recenter_btn: Button = %RecenterBtn
@onready var _stats_label: Label = %StatsLabel
#endregion


#region Node base
func _ready() -> void:
	_regenerate_btn.pressed.connect(_on_regenerate_pressed)
	_recenter_btn.pressed.connect(_on_recenter_pressed)
	_auto_fill_targets_btn.pressed.connect(_on_auto_fill_targets_pressed)
	_level_count.value_changed.connect(_on_level_count_changed)
	_angular_jitter.value_changed.connect(_on_angular_jitter_changed)
	_decay_exponent.value_changed.connect(_on_decay_exponent_changed)
	_zoom_slider.value_changed.connect(_on_zoom_changed)
	_world_viewport.gui_input.connect(_on_world_viewport_input)
	resized.connect(_recenter_world)
	_on_angular_jitter_changed(_angular_jitter.value)
	_on_decay_exponent_changed(_decay_exponent.value)
	_on_zoom_changed(_zoom_slider.value)
	_rebuild_targets_grid(int(_level_count.value))
	_on_auto_fill_targets_pressed()
	_recenter_world()
	_regenerate()
#endregion


#region Private functions
func _regenerate() -> void:
	var gen: MapTreeGenerator = MapTreeGenerator.new()
	_apply_generator_params(gen)
	gen.level_targets_override = _read_targets_override()
	var graph: MapTreeGenerator.Graph = gen.generate()
	_last_graph = graph
	_render(graph)


func _apply_generator_params(gen: MapTreeGenerator) -> void:
	gen.seed = int(_seed_field.text) if _seed_field.text.is_valid_int() else 0
	gen.total_node_target = int(_total_nodes.value)
	gen.level_count = int(_level_count.value)
	gen.root_branches = int(_root_branches.value)
	gen.min_children = int(_min_children.value)
	gen.max_children = int(_max_children.value)
	gen.ring_spacing = _ring_spacing.value
	gen.decay_exponent = _decay_exponent.value
	gen.angular_jitter_factor = _angular_jitter.value
	gen.radial_jitter_px = _radial_jitter.value
	gen.min_angular_gap_px = _min_angular_gap.value
	gen.min_node_distance_px = _min_node_distance.value


func _read_targets_override() -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	for sb in _level_target_spinboxes:
		out.append(int(sb.value))
	return out


func _rebuild_targets_grid(count: int) -> void:
	for child in _level_targets_grid.get_children():
		child.queue_free()
	_level_target_spinboxes.clear()
	for L in range(1, count + 1):
		var label: Label = Label.new()
		label.text = "L%d" % L
		label.custom_minimum_size = Vector2(28, 0)
		_level_targets_grid.add_child(label)
		var sb: SpinBox = SpinBox.new()
		sb.min_value = 1
		sb.max_value = 99
		sb.value = 1
		sb.custom_minimum_size = Vector2(60, 0)
		_level_targets_grid.add_child(sb)
		_level_target_spinboxes.append(sb)


func _render(graph: MapTreeGenerator.Graph) -> void:
	for child in _islands_root.get_children():
		child.queue_free()
	_paths.set_segments([])

	var invalid_set: Dictionary = {}
	for id in graph.invalid_ids:
		invalid_set[id] = true

	var node_by_id: Dictionary = {}
	for node in graph.nodes:
		var island: LevelSelectorIsland = ISLAND_SCENE.instantiate()
		island.island_id = StringName("proto_n_%d" % node.id)
		island.tier = node.level + 1
		island.display_title = "Départ" if node.level == 0 else str(node.level)
		island.display_subtitle = "id %d" % node.id
		island.radius = 56.0 if node.level > 0 else 78.0
		island.body_color = _ring_color(node.level)
		island.position = node.position
		_islands_root.add_child(island)
		island.set_state(LevelSelectorIsland.State.REACHABLE)
		if invalid_set.has(node.id):
			island.modulate = INVALID_NODE_TINT
		node_by_id[node.id] = node

	var segs: Array = []
	for edge in graph.edges:
		var from_node = node_by_id.get(edge.from_id)
		var to_node = node_by_id.get(edge.to_id)
		if from_node == null or to_node == null:
			continue
		segs.append([from_node.position, to_node.position])
	_paths.set_segments(segs)

	_update_stats(graph)


func _update_stats(graph: MapTreeGenerator.Graph) -> void:
	var total_nodes: int = graph.nodes.size()
	var rescue_count: int = 0
	for e in graph.edges:
		if e.kind == MapTreeGenerator.EdgeKind.CROSS:
			rescue_count += 1
	var per_level: Array = []
	for L in range(graph.by_level.size()):
		per_level.append(graph.by_level[L].size())
	var valid_str: String = "valide" if graph.is_valid else "INVALIDE (%d nodes fautifs)" % graph.invalid_ids.size()
	_stats_label.text = "%d nodes, %d rescues — %s\npar anneau: %s" % [total_nodes, rescue_count, valid_str, str(per_level)]


func _ring_color(level: int) -> Color:
	if level == 0:
		return Color(0.95, 0.78, 0.35, 1.0)
	var hue: float = fmod(0.42 + float(level) * 0.083, 1.0)
	return Color.from_hsv(hue, 0.55, 0.85)


func _recenter_world() -> void:
	_world.position = Vector2(PANEL_WIDTH + (size.x - PANEL_WIDTH) * 0.5, size.y * 0.5)


#endregion


#region Callbacks
func _on_regenerate_pressed() -> void:
	_regenerate()


func _on_recenter_pressed() -> void:
	_zoom_slider.value = 1.0
	_recenter_world()


func _on_auto_fill_targets_pressed() -> void:
	# Génère un graph avec override vide → on récupère les targets calculés par la formule
	# et on les copie dans les SpinBoxes. Point de départ pour ajustements manuels.
	var gen: MapTreeGenerator = MapTreeGenerator.new()
	_apply_generator_params(gen)
	gen.level_targets_override = PackedInt32Array()
	var graph: MapTreeGenerator.Graph = gen.generate()
	for L in range(1, graph.by_level.size()):
		var idx: int = L - 1
		if idx < _level_target_spinboxes.size():
			_level_target_spinboxes[idx].value = graph.by_level[L].size()


func _on_level_count_changed(value: float) -> void:
	_rebuild_targets_grid(int(value))
	_on_auto_fill_targets_pressed()


func _on_angular_jitter_changed(value: float) -> void:
	_angular_jitter_label.text = "Jitter angulaire : %.2f" % value


func _on_decay_exponent_changed(value: float) -> void:
	_decay_exponent_label.text = "Décroissance par niveau : %.2f" % value


func _on_zoom_changed(value: float) -> void:
	_world.scale = Vector2.ONE * value
	_zoom_label.text = "Zoom : %.2f×" % value


func _on_world_viewport_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			return
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_slider.value = min(_zoom_slider.max_value, _zoom_slider.value + ZOOM_STEP)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_slider.value = max(_zoom_slider.min_value, _zoom_slider.value - ZOOM_STEP)
	elif event is InputEventMouseMotion and _is_panning:
		_world.position += event.relative
#endregion
