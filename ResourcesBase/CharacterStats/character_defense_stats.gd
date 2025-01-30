extends Resource
class_name CharacterDefenseStats

@export var periodic_armor_stacks_amount: int # Stacks of armor gain every periodic_armor_stacks_period
@export var periodic_armor_stacks_period: float # Time between 2 gain of stacks of periodic armor (in s)

@export var backfire_poison_stacks: int # Poison stacks number backfired to enemy
@export var backfire_poison_chance: int # Chance to backfire poison stacks when hit (in s)

@export var backfire_armor_gain_stacks: int # Stacks of armor gain when being hit
@export var backfire_armor_gain_chance: int # % of chance to proc the armor gain when being hit

@export var shield_strike_damage_percent: float # % of armor lost during shield_strike_period returned as damage
@export var shield_strike_period: float # Time between 2 shield strike (in s)

@export var backfire_fire_shield_damage: float # Damage done to enemy when being hit (in % of current enemy hp)
@export var backfire_fire_shield_chance: int # % of chance to proc the backfire_fire_shield

@export var healing_armor_percent: int # % of heal done also apply armor

@export var backfire_vulnerability_stacks: int # Stacks of vulnerability applied to enemy when being hit
@export var backfire_vulnerability_chance: int # % of chance to proc the backfire_vulnerability

@export var lost_hp_armor_gain_percent : int # % of lost hp converted into armor stacks
@export var lost_hp_armor_gain_period : float # Time between two lost_hp_armor_gain (in s)

@export var movement_armor_stacks_amount: int # Stacks of armor gain every movement_armor_stacks_distance moved
@export var movement_armor_stacks_distance: int # Distance to move to gain movement_armor_stacks (in m)

@export var reduce_damage_received: int # % of damage received reduced
@export var reduce_damage_done: int # % of damage done reduced
