class_name CharacterAutoAttackStats
extends Resource

var storm_hammer_activated: bool # True if this skill is activated
var storm_hammer_chance: int # % of chance for an auto-attack to bounce

var gatling_gun_activated: bool # True if this skill is activated
var gatling_gun_min: int # Min value of the attack speed increased overtime
var gatling_gun_max: int # Max value of the attack speed increased overtime
var gatling_gun_duration: int # Time needed to go from min to max attack speed increase

var double_edge_sword_activated: bool # True if this skill is activated
var double_edge_sword_damage_percent: int # % of damage increased
var double_edge_sword_attacks_number: int # Number oof attacks boosted

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
