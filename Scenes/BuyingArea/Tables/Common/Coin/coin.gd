class_name Coin
extends StaticBody3D

@onready var coin_collision: CollisionShape3D = %CoinCollision

func get_height() -> float:
	return (coin_collision.shape as CylinderShape3D).height
