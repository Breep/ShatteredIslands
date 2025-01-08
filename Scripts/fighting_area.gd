extends Node2D
class_name FightingArea

# ============================== Local scene nodes ==============================

@onready var selectionSquareSprite: Sprite2D = $SelectionSquare/SquareSprite
@onready var tileMap: TileMapLayer = $Map
@onready var selectionMap: TileMapLayer = $Map/SelectionLayer

# ============================== Private ==============================

var _selectionCell: Vector2 = Vector2.ZERO
var _selectionCellOld: Vector2 = Vector2.ZERO

# ============================== Public ==============================

var isSelectionActive: bool = false

var selectionCell: Vector2:
	get:
		return _selectionCell
	set(value):
		_selectionCellOld = _selectionCell
		_selectionCell = value
		_drawSelectionCell(_selectionCell)

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Select"):
		_updateSelection(_getMouseOveringCell())

# ============================== Private functions ==============================

func _updateSelection(cell: Vector2) -> void:
	if cell == _selectionCell and isSelectionActive == true:
		isSelectionActive = false
		selectionMap.erase_cell(_selectionCell)
	else:
		isSelectionActive = true
		selectionCell = cell

func _drawSelectionCell(cell: Vector2) -> void:
	if isSelectionActive:
		selectionMap.erase_cell(_selectionCellOld)
		selectionMap.set_cell(cell, 0, Vector2(0,0), 0)

func _getMouseOveringCell() -> Vector2:
	return tileMap.local_to_map(tileMap.get_local_mouse_position())

# ============================== public functions ==============================

func getGlobalCellPosition(cell: Vector2) -> Vector2:
	return to_global(tileMap.map_to_local(cell))
