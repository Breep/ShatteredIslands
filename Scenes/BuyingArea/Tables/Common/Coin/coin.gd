class_name Coin
extends StaticBody3D

# ============================== Local nodes ==============================

@onready var coin_collision: CollisionShape3D = %CoinCollision

# ============================== Public functions ==============================

func get_height() -> float:
	return (coin_collision.shape as CylinderShape3D).height
