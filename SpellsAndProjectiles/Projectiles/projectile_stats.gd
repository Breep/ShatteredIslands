class_name ProjectileStats
extends Resource

var speed: int # Speed of the projectile

var physical_base_damage: float # Physical damage before crit
var physical_damage_flat: float # Physicial damage of the projectile
var physical_is_critical: bool

var magical_base_damage: float # Magical damage before crit
var magical_damage_flat: float # Physicial damage of the projectile
var magical_is_critical: bool

var is_bouncing: bool # If the projectile should bounce on the enemy

var poison_stacks: int # Number of poison stacks within the projectile
var poison_stacks_is_critical: bool

var on_hit_logic_callbacks : Array[Callable] # var: Dictionary
var on_hit_visual_callbacks : Array[Callable] # var: Dictionary
