extends Node2D
class_name FightingArea

# ==============================================================================

@onready var selectionSquareSprite: Sprite2D = $SelectionSquare/SquareSprite
@onready var tileMap: TileMapLayer = $Map
@onready var selectionMap: TileMapLayer = $Map/SelectionLayer

# ==============================================================================

var _selectionCell: Vector2 = Vector2.ZERO
var _selectionCellOld: Vector2 = Vector2.ZERO

# ==============================================================================

var isSelectionActive: bool = false

@export var selectionCell: Vector2:
	get:
		return _selectionCell
	set(value):
		_selectionCellOld = _selectionCell
		_selectionCell = value
		drawSelectionCell(_selectionCell)

# ==============================================================================

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Select"):
		updateSelection(_getMouseOveringCell())

# ==============================================================================

func updateSelection(cell: Vector2) -> void:
	print(cell, _selectionCell, _selectionCellOld, isSelectionActive)
	if cell == _selectionCell and isSelectionActive == true:
		isSelectionActive = false
		selectionMap.erase_cell(_selectionCell)
	else:
		isSelectionActive = true
		selectionCell = cell

func drawSelectionCell(cell: Vector2) -> void:
	if isSelectionActive:
		selectionMap.erase_cell(_selectionCellOld)
		selectionMap.set_cell(cell, 0, Vector2(0,0), 0)

func getGlobalCellPosition(cell: Vector2) -> Vector2:
	return to_global(tileMap.map_to_local(cell))

# ==============================================================================

func _getMouseOveringCell() -> Vector2:
	return tileMap.local_to_map(tileMap.get_local_mouse_position())
