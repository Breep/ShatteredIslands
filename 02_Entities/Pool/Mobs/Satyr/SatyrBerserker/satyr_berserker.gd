class_name SatyrBerserker
extends Entity

func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("satyr_die", global_position)
