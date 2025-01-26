class_name AutoAttackProjectileStats
extends Resource

var speed: int # Speed of the projectile

var damage: int # Physicial dammage of the projectile

var isCritic: bool # If the projectile is a critical

var isBouncing: bool # If the projectile should bounce on the enemy

var poison_stacks: int # Number of poison stacks within the projectile
var poison_duration: int # Duration of the poison stacks (in ticks)

var vulnerability_stacks: int # Number of vulnerability stacks within the projectile
var vulnerability_duration: int # Duration of the vulnerability stacks (in ticks)
