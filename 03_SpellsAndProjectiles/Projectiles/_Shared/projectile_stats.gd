class_name ProjectileStats
extends Resource

enum VarType { # Variable types of the callbacks
	SOURCE,
	TARGET,
	PROJECTILE,
	POSITION
}

@export var speed: int # Speed of the projectile

@export var bounces_remaining: float = 0 # number of bounce

@export var on_spawn_callbacks: Array[Callable] # var: Dictionary
@export var on_hit_callbacks: Array[Callable] # var: Dictionary
