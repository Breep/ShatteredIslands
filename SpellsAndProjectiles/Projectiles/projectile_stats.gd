class_name ProjectileStats
extends Resource

var speed: int # Speed of the projectile

var physical_damage_flat: int # Physicial damage of the projectile
var physical_damage_percent: float # Damage done in addition to damage (in % of enemy hp)
var physical_damage_percent_type: Utils.PercentModifier # Max, Current or Lost HP
var physical_is_critical: bool

var magical_damage_flat: int # Physicial damage of the projectile
var magical_damage_percent: float # Damage done in addition to damage (in % of enemy hp)
var magical_damage_percent_type: Utils.PercentModifier # Max, Current or Lost HP
var magical_is_critical: bool

var is_bouncing: bool # If the projectile should bounce on the enemy

var poison_stacks: int # Number of poison stacks within the projectile
var poison_stacks_is_critical: bool

var on_hit_logic_callbacks : Array[Callable] # var: Dictionary
var on_hit_visual_callbacks : Array[Callable] # var: Dictionary
