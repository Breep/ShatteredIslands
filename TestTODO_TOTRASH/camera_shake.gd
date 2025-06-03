extends Camera2D

@export var randomStrenght: float = 30.0
@export var shakeFade: float = 5.0

var rng= RandomNumberGenerator.new()

var shake_strenght: float =0.0

func _ready():
	pass
	
func apply_shake():
	shake_strenght = randomStrenght
		
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strenght,shake_strenght),rng.randf_range(-shake_strenght,shake_strenght))
