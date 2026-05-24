extends Projectile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_3d("fire_ball_projectile", global_position, 0.95)
	super._ready()
