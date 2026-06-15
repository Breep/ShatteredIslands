class_name Geri
extends Entity

func cast_ultimate() -> void:
	super.cast_ultimate()
	AudioManager.play_3d("wolf_howl", global_position)


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("wolf_die", global_position)
