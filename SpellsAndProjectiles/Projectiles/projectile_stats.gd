class_name ProjectileStats
extends Resource

var speed: int # Speed of the projectile

var physical_damage_flat: int # Physicial damage of the projectile
var physical_damage_percent: float # Damage done in addition to damage (in % of enemy hp)
var physical_damage_percent_type: Utils.PercentModifier # Max, Current or Lost HP

var magical_damage_flat: int # Physicial damage of the projectile
var magical_damage_percent: float # Damage done in addition to damage (in % of enemy hp)
var magical_damage_percent_type: Utils.PercentModifier # Max, Current or Lost HP

var is_critic: bool # If the projectile is a critical

var is_bouncing: bool # If the projectile should bounce on the enemy

var poison_stacks: int # Number of poison stacks within the projectile
