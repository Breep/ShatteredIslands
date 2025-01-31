extends Resource
class_name CharacterHealStats

@export var periodic_heal_amount: int # Amount of heal done to an ally every periodic_heal_period
@export var periodic_heal_period: int # time between 2 heal from periodic_heal_amount (in s)

@export var heal_projectile_damage: int # Damage done by the healing projectile
@export var heal_projectile_chance: int # % of chance to send a heal_projectile every time the character heals someone

@export var pacify_enemy_attack_number: int # Number of attacks pacified on the enemy
@export var pacify_enemy_chance: int # % of chance to proc the pacify_enemy_attack_number after a heal

@export var heal_area_activated: int # If the epic healing area is activated
@export var heal_area_percentage: int # % of max life healed
@export var heal_area_period: float # time between 2 heal from the epic area (in s)

@export var lost_hp_regen_percentage: float # % of lost hp healed each lost_hp_regen_period
@export var lost_hp_regen_period: float # time between 2 heal from the lost_hp_regen_percentage (in s)

@export var poison_stacks_number: int # Number of poison stack applied after a heal
@export var poison_stacks_chance: int # % of chance to trigger poison_stacks_number

@export var movement_heal_amount : int # Amount of heal done to an ally every movement_heal_distance moved
@export var movement_heal_distance : int # Distance needed to activate movement_heal_amount (in m)
