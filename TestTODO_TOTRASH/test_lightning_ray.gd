extends Node2D

@onready var line = %Thunder

func _ready():
	pass
	

func raycast_coordonate(player1 : Vector2, player2: Vector2):
	line.points[0].x = player1.x
	line.points[0].y = player1.y
	line.points[1].x = player2.x
	line.points[1].y = player2.y
	
func cast_to():
	#Raycast.instantiate()
	return
