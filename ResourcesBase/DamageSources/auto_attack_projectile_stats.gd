class_name AutoAttackProjectileStats
extends Resource

var speed: int # Speed of the projectile

var damage: int # Physicial dammage of the projectile

var is_critic: bool # If the projectile is a critical

var is_bouncing: bool # If the projectile should bounce on the enemy

var poison_stacks: int # Number of poison stacks within the projectile
var poison_duration: int # Duration of the poison stacks (in ticks)

var vulnerability_stacks: int # Number of vulnerability stacks within the projectile

var fire_active: bool # If the projectile is on the fire condition (will do damage based on current target hp)
var fire_damage: float # Damage done in addition to normal auto attack (in % of current enemy hp)
