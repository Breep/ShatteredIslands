class_name Vrock
extends Entity

func _ready() -> void:
	super._ready()
	ultimate_casted.connect(_on_ultimate_casted)


func _on_ultimate_casted() -> void:
	AudioManager.play_3d("wolf_howl", global_position)
