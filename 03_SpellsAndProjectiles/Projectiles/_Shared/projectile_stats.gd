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

# Level résolu par ProjectileComponent avant le spawn (base + modifiers
# level_modifier_callback). Lu par les sous-classes de Projectile pour indexer
# leurs Array @export par-level (damage, hit_radius, etc.).
@export var level: int = 1

# Id d'attribution pour le pipeline damage/alterations (typiquement card_name
# côté carte). Lu par les sous-classes pour passer aux appels damage.direct().
@export var source_id: StringName = &""

@export var on_spawn_callbacks: Array[Callable] # var: Dictionary
@export var on_hit_callbacks: Array[Callable] # var: Dictionary
