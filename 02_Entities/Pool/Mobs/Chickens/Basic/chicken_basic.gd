class_name ChickenBasic
extends Chicken

func _ready() -> void:
	super._ready()
	AudioManager.play_3d("chicken_bok_bok_01", global_position)
