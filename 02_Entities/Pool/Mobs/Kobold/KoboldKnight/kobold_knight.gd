class_name KoboldKnight
extends Entity

func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("kobold_die_01", global_position)
