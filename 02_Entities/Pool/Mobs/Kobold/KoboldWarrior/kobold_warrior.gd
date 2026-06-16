class_name KoboldWarrior
extends Entity

func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("kobold_die_03", global_position)
