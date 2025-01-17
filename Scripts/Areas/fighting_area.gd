extends Node2D
class_name FightingArea

# ============================== Public variables ==============================

var is_selection_active: bool = false

var selection_cell: Vector2:
	get:
		return _selection_cell
	set(value):
		_selection_cell_old = _selection_cell
		_selection_cell = value
		_draw_selection_cell(_selection_cell)

# ============================== Private variables ==============================

var _selection_cell: Vector2 = Vector2.ZERO
var _selection_cell_old: Vector2 = Vector2.ZERO

# ============================== Local scene nodes ==============================

@onready var _tile_map: TileMapLayer = %Map
@onready var _selection_map: TileMapLayer = %SelectionLayer

# ============================== Node base functions ==============================

func _ready() -> void:
	print("Fighting Area ready !")
	print(_tile_map, " ", _selection_map)
	pass


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Select"):
		_update_selection(_get_mouse_overing_cell())


func _on_timer_timeout() -> void:
	GameManager.game_switch_to(GameManager.GameState.Buying)

# ============================== public functions ==============================

func get_global_cell_position(cell: Vector2) -> Vector2:
	return to_global(_tile_map.map_to_local(cell))

# ============================== Private functions ==============================

func _update_selection(cell: Vector2) -> void:
	if cell == _selection_cell and is_selection_active == true:
		is_selection_active = false
		_selection_map.erase_cell(_selection_cell)
	else:
		is_selection_active = true
		selection_cell = cell


func _draw_selection_cell(cell: Vector2) -> void:
	if is_selection_active:
		_selection_map.erase_cell(_selection_cell_old)
		_selection_map.set_cell(cell, 0, Vector2(0,0), 0)


func _get_mouse_overing_cell() -> Vector2:
	return _tile_map.local_to_map(_tile_map.get_local_mouse_position())
