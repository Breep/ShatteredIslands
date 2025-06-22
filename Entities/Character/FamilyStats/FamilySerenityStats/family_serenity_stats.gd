class_name FamilySerenityStats
extends FamilyStats

# Current pacify stacks on the hero (reduce auto attack damage)
# Decreases by attacking: 1 auto attack = 1 pacify stack consumed
var pacify_stacks: int = 0

var periodic_heal_activated: bool # True if the player has at least one of this card
var periodic_heal_amount: int # Amount of heal done to an ally every periodic_heal_period
var periodic_heal_period: float # time between 2 heal from periodic_heal_amount (in s)

var heal_projectile_activated: bool # If the skill is activated
var heal_projectile_damage: int # Damage done by the healing projectile
var heal_projectile_chance: int # % of chance to send a heal_projectile every time the character heals someone

var pacified: bool # If the character is pacified (HealManager set this, Character attack use it)
var pacify_enemy_activated: bool # If the skill is activated
var pacify_enemy_chance: int # % of chance to proc the pacify_enemy_attack_number after a heal

var epic_heal_area_activated: int # If the epic healing area is activated
var epic_heal_area_percentage: int # % of max life healed
var epic_heal_area_period: float # time between 2 heal from the epic area (in s)

var lost_hp_regen_activated: bool # If the skill is activated
var lost_hp_regen_percentage: float # % of lost hp healed each lost_hp_regen_period
var lost_hp_regen_period: float # time between 2 heal from the lost_hp_regen_percentage (in s)

var poison_stacks_activated: bool # If this skill is activated
var poison_stacks_number: int # Number of poison stack applied after a heal
var poison_stacks_chance: int # % of chance to trigger poison_stacks_number
