class_name ForestDrake
extends Entity


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("forest_drake_die", global_position)
