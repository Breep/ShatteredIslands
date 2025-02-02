class_name CharacterAutoAttackStats
extends Resource

@export var damage: int # Damage of auto attack

@export var attack_speed: float # Attack per second
@export var critical_chance: float # % of chance for an auto attack to do critical damage
@export var critical_multiplier: float # Critical damage multiplier (2 per default)

var attack_speed_boost: float # Percentage of attack speed increased

var attack_speed_overtime_current: float # Current value of percentage of attack speed increased overtime
var attack_speed_overtime_min: float # Min value of percentage of attack speed increased overtime
var attack_speed_overtime_max: float # Max value of percentage of attack speed increased overtime
var attack_speed_overtime_duration: float # Time needed to go from min to max attack speed increase


var poison_stacks_amount: int # Number of poison stacks applied for with an auto attack
var poison_stacks_chance: float # % of chance to proc the poison stacks

var vulnerability_stacks_amount: int # Number of vulnerability stacks applied for with an auto attack
var vulnerability_stacks_chance: float # % of chance to proc the vulnerability stacks

var bounce_chance: float # % of chance to proc a bouncing attack (attack continue to an second enemy after hitting the first)

var double_attack_chance: float # % of chance to proc a double attack

var healing_attack_heal_amount: int # Heal amount applied to an ally (can be self) when  auto attacking
var healing_attack_chance: float # % of chance to proc healing attack

var armor_stacks_amount: int  # Number of armor stacks applied for with an auto attack
var armor_stacks_chance: float  # % of chance to proc the armor stacks

var fire_attack_activated: bool  # If the fire attack is activated
var fire_attack_damage: float  # Damage done in addition to normal auto attack (in % of current enemy hp)
var fire_attack_period: int  # Number of auto attacks between 2 fire_attack
var fire_attack_triggered: bool # Tell the projectile to activate its "FIRE" condition (it is set by the character)

var increase_max_hp_activated: bool  # If the increase max hp is activated
var increase_max_hp_amount: int  # Amount of max hp increased every increase_max_hp_period auto attack
var increase_max_hp_period: int  # Number of auto attacks between 2 increase_max_hp

var movement_increase_damage_amount: int  # Amount of auto attack damage increase
var movement_increase_damage_distance: float  # Distance needed to move to increase auto attack damage
