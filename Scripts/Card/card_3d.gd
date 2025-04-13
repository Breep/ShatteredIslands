class_name Card3D
extends StaticBody3D

# ============================== Local nodes ==============================

@onready var _card_collision: CollisionShape3D = %Card3DCollision
@onready var _card_3d_visual: Card3dVisual = %Card3DVisual

# ============================== Public functions ==============================

func get_height() -> float:
	return (_card_collision.shape as BoxShape3D).size.y


func set_color(color: Color) -> void:
	_card_3d_visual.set_color(color)
