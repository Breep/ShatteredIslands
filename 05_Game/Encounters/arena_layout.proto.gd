# Proto for ArenaLayout: drag a .tres into the slot to load it, click tiles to cycle their camp,
# right-click to clear, click "Save" to persist. Doubles as the V1 creation tool for arena layouts.
extends Node3D


# ============================== Export ==============================
#region Export
@export var arena_layout: ArenaLayout : set = _set_arena_layout

@export_group("Camp Colors")
@export var color_player_camp: Color = Color(0.30, 0.55, 0.95, 0.75)
@export var color_enemy_camp: Color = Color(0.90, 0.30, 0.30, 0.75)
@export var color_no_camp: Color = Color(0.30, 0.30, 0.35, 0.30)

@export_group("Saving")
@export_file("*.tres") var save_path: String = "res://05_Game/Encounters/arena_layouts/test_layout.tres"
#endregion


# ============================== Private variables ==============================
#region Private variables
@onready var _hex_grid: HexGrid = $HexGrid
@onready var _status_label: Label = $UI/Panel/StatusLabel
@onready var _save_btn: Button = $UI/Panel/SaveBtn
@onready var _clear_btn: Button = $UI/Panel/ClearBtn
#endregion


# ============================== Node base functions ==============================
#region Node base functions
func _ready() -> void:
	_hex_grid.tile_clicked.connect(_on_tile_clicked)
	_hex_grid.grid_rebuilt.connect(_on_grid_rebuilt)
	_save_btn.pressed.connect(_on_save_pressed)
	_clear_btn.pressed.connect(_on_clear_pressed)
	if arena_layout == null:
		arena_layout = ArenaLayout.new()
		_set_status("Created empty in-memory layout. Set save_path before saving.")
	_apply_layout_colors()
#endregion


# ============================== Private functions ==============================
#region Private functions
func _apply_layout_colors() -> void:
	if arena_layout == null or _hex_grid == null: return
	arena_layout.apply_to_hex_grid(_hex_grid, color_player_camp, color_enemy_camp, color_no_camp)


func _refresh_tile(coord: Vector2i) -> void:
	if arena_layout == null or _hex_grid == null: return
	var camp: ArenaLayout.Camp = arena_layout.get_camp_for_hex(coord)
	var c: Color = color_no_camp
	match camp:
		ArenaLayout.Camp.PLAYER: c = color_player_camp
		ArenaLayout.Camp.ENEMY:  c = color_enemy_camp
	_hex_grid.set_tile_color(coord, c)


func _set_status(msg: String) -> void:
	if _status_label != null:
		_status_label.text = msg
	Verbose.debug("[ArenaLayoutProto] " + msg, Verbose.Category.DEFAULT)
#endregion


# ============================== Callbacks ==============================
#region Callbacks
func _on_tile_clicked(coord: Vector2i, button_index: int) -> void:
	if arena_layout == null: return
	if button_index == MOUSE_BUTTON_LEFT:
		var current: ArenaLayout.Camp = arena_layout.get_camp_for_hex(coord)
		var next: ArenaLayout.Camp = ArenaLayout.Camp.NONE
		match current:
			ArenaLayout.Camp.NONE:   next = ArenaLayout.Camp.PLAYER
			ArenaLayout.Camp.PLAYER: next = ArenaLayout.Camp.ENEMY
			ArenaLayout.Camp.ENEMY:  next = ArenaLayout.Camp.NONE
		arena_layout.set_camp_for_hex(coord, next)
		_refresh_tile(coord)
	elif button_index == MOUSE_BUTTON_RIGHT:
		arena_layout.set_camp_for_hex(coord, ArenaLayout.Camp.NONE)
		_refresh_tile(coord)


func _on_grid_rebuilt() -> void:
	_apply_layout_colors()


func _on_save_pressed() -> void:
	if arena_layout == null:
		_set_status("No arena_layout to save")
		return
	if save_path == "":
		_set_status("save_path is empty")
		return
	var dir_path: String = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir_path)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
	var err: int = ResourceSaver.save(arena_layout, save_path)
	if err == OK:
		_set_status("Saved %d player + %d enemy hexes to %s" % [
			arena_layout.player_camp_hexes.size(),
			arena_layout.enemy_camp_hexes.size(),
			save_path
		])
	else:
		_set_status("Save failed (err=%d)" % err)


func _on_clear_pressed() -> void:
	if arena_layout == null: return
	arena_layout.clear_all()
	_apply_layout_colors()
	_set_status("Cleared all camp assignments")
#endregion


# ============================== Setters ==============================
#region Setters
func _set_arena_layout(v: ArenaLayout) -> void:
	arena_layout = v
	if is_inside_tree():
		_apply_layout_colors()
#endregion
