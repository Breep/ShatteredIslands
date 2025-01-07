extends Node2D

# ==============================================================================

@export var mapSize : Vector2
@export var cellSize : int
# coucou
# ==============================================================================

@onready var selectionSquare : Node2D = $SelectionSquare
@onready var selectionSquareSprite : Sprite2D = $SelectionSquare/SquareSprite
@onready var tileMap : TileMapLayer = $TileMapLayer # Must be at local position (0,0)

# ==============================================================================

func _ready() -> void:
	_setSelectionSquareSpriteScale()
	printSelectionSquareAtCell(Vector2(0, 0))

func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Select"):
		printSelectionSquareAtCell(_getMouseOveringCell())

# ==============================================================================

func getActiveCell() -> Vector2:
	return (selectionSquare.position/cellSize).floor()

func printSelectionSquareAtCell(cell : Vector2) -> void:
	if cell == getActiveCell() && selectionSquare.visible == true:
		selectionSquare.visible = false
	else:
		selectionSquare.visible = true
	selectionSquare.position = cell * cellSize

# ==============================================================================

func _setSelectionSquareSpriteScale():
	var textureSize = selectionSquareSprite.texture.get_size()
	selectionSquareSprite.scale.x = cellSize / textureSize.x
	selectionSquareSprite.scale.y = cellSize / textureSize.y
	selectionSquareSprite.position.x = cellSize / 2
	selectionSquareSprite.position.y = cellSize / 2

func _getMouseOveringCell() -> Vector2:
	return (get_local_mouse_position()/cellSize).floor()
