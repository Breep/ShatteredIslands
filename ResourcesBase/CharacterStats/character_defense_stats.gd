extends Resource
class_name CharacterDefenseStats

# Current armor on the character (like a shield, a second health bar)
# Decreases by taking damage: 1 damage = 1 armor stack consumed
var armor_stacks: int = 0

var periodic_armor_stacks_amount: int # Stacks of armor gain every periodic_armor_stacks_period
var periodic_armor_stacks_period: float # Time between 2 gain of stacks of periodic armor (in s)

var backfire_poison_stacks: int # Poison stacks number backfired to enemy
var backfire_poison_chance: int # Chance to backfire poison stacks when hit (in s)

var backfire_armor_gain_stacks: int # Stacks of armor gain when being hit
var backfire_armor_gain_chance: int # % of chance to proc the armor gain when being hit

var shield_strike_damage_percent: float # % of armor lost during shield_strike_period returned as damage
var shield_strike_period: float # Time between 2 shield strike (in s)

var backfire_fire_shield_damage: float # Damage done to enemy when being hit (in % of current enemy hp)
var backfire_fire_shield_chance: int # % of chance to proc the backfire_fire_shield

var healing_armor_percent: int # % of heal done also apply armor

var backfire_vulnerability_stacks: int # Stacks of vulnerability applied to enemy when being hit
var backfire_vulnerability_chance: int # % of chance to proc the backfire_vulnerability

var lost_hp_armor_gain_percent : int # % of lost hp converted into armor stacks
var lost_hp_armor_gain_period : float # Time between two lost_hp_armor_gain (in s)

var reduce_damage_received: int # % of damage received reduced
var reduce_damage_done: int # % of damage done reduced
