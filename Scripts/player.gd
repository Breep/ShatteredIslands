extends StaticBody2D

# ==============================================================================

var fightingAreaNode: Node2D

# ==============================================================================

func _ready() -> void:
	fightingAreaNode = get_tree().get_root().find_child("FightingArea", true, false)

func _physics_process(delta: float) -> void:
	pass

# ==============================================================================

func _input(_event: InputEvent) -> void:
	pass

# ==============================================================================

func moveToCell(cell : Vector2):
	position = (cell + 0.5*Vector2(1,1)) * fightingAreaNode.cellSize
	print("Moving to " + str(cell))

# ==============================================================================

func _on_timer_timeout() -> void:
	moveToCell(fightingAreaNode.getActiveCell())
