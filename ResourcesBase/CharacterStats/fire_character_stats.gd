extends Resource
class_name FireCharacterStats

@export var firebolt_damage: float # Damage of the firebolt (in % of enemy current hp)
@export var firebolt_period: float # Period of time between 2 firebolts (in s)

@export var magic_resist_percent: int # % # Reduce magic damage taken by this amount (in %)

@export var meteor_damage: int # Meteor damage (in % of enemy current hp)
@export var meteor_cooldown: float # Time before a meteor is called after the last one landed (in s)
@export var meteor_deploy_time: float # Time for the meteor to land (in s)
@export var meteor_area_range: int # Range of the meteor impact

@export var nuke_damage: float # Nuke damage (in % of enemy current hp)
@export var nuke_period: float # Period of time between 2 nukes

@export var healing_fire_area_damage: float # Healing fire area damage (in % of enemies current hp)
@export var healing_fire_area_heal: float # Healing fire area heal (in % of allies current hp)
@export var healing_fire_area_range: int # Healing fire area range
@export var healing_fire_area_period: float # Time between 2 tick of damage/heal of the healing fire

@export var damage_increase_on_low_life_enemy_percent: int # Damage increase on enemies below a threshold (in %)
@export var damage_increase_on_low_life_enemy_threshold: int # Threshold of the damage increase (in % of max hp)

@export var hp_fire_damage: int # Damage of the hp fire (in % of self max hp)
@export var hp_fire_period: float # Time between 2 hp fire (in s)

@export var poison_fire_stacks_lost: int # Number of stack to be lost by the enemy to proc poison_fire
@export var poison_fire_damage: int # Damage of the poison fire (in % of enemy max hp)

@export var trail_damage : int # Fire trail damage (in % of enemy current hp)
@export var trail_life_time : float # Fire trial life time (in s)
@export var trail_period : float # Time between 2 tick of damage of fire trail
