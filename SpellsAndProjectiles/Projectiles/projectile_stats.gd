class_name ProjectileStats
extends Resource

enum VarType { # Variable types of the callbacks
	SOURCE,
	TARGET,
	PROJECTILE,
	POSITION
}

var speed: int # Speed of the projectile

var bounces_remaining: int = 0 # number of bounce

var on_spawn_callbacks: Array[Callable] # var: Dictionary
var on_hit_callbacks: Array[Callable] # var: Dictionary
