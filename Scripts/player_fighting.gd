extends StaticBody2D

# ==============================================================================

@onready var fightingArea: FightingArea = get_tree().get_root().find_child("FightingArea", true, false)

# ==============================================================================

func _ready() -> void:
	moveToCell(Vector2(0,0))

func _physics_process(delta: float) -> void:
	pass

# ==============================================================================

func _input(_event: InputEvent) -> void:
	pass

# ==============================================================================

func moveToCell(cell : Vector2):
	position = fightingArea.getGlobalCellPosition(cell)
	print("Moving to " + str(cell))

# ==============================================================================

func _on_timer_timeout() -> void:
	if fightingArea.isSelectionActive:
		moveToCell(fightingArea.selectionCell)
