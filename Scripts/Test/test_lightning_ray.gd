extends RayCast2D


@onready var line = %lightningray
@onready var end = %endray

func _ready():
	pass
	
func _physics_process(delta):
	if is_colliding():
		var coll_point = to_local(get_collision_point())
		line.points[1].x = coll_point.x
		end.position.x = coll_point.x - 15

func raycast_coordonate(player1 : Vector2, player2: Vector2):
	line.points[0].x = player1.x
	line.points[0].y = player1.y
	line.points[1].x = player2.x
	line.points[1].y = player2.y
	
func cast_to():
	#Raycast.instantiate()
	return
