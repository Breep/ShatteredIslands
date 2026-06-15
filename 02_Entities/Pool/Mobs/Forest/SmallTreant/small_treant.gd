class_name SmallTreant
extends Entity


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("tree_falling", global_position)
