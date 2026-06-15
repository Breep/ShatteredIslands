class_name Geri
extends Entity

func _ready() -> void:
	super._ready()
	ultimate_casted.connect(_on_ultimate_casted)


func _on_ultimate_casted() -> void:
	AudioManager.play_3d("wolf_howl", global_position)


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("wolf_die", global_position)
