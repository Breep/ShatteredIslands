extends Resource
class_name CharacterFireStats

var firebolt_activated: bool # True if the player has at least one of this card
var firebolt_damage: float # Damage of the firebolt (in % of enemy current hp)
var firebolt_period: float # Period of time between 2 firebolts (in s)

var magic_resist_percent: int # % # Reduce magic damage taken by this amount (in %)

var meteor_activated: bool # True if the player has at least one of this card
var meteor_damage: int # Meteor damage (in % of enemy current hp)
var meteor_cooldown: float # Time before a meteor is called after the last one landed (in s)
var meteor_deploy_time: float # Time for the meteor to land (in s)
var meteor_area_range: int # Range of the meteor impact

var nuke_activated: bool # True if the player has at least one of this card
var nuke_damage: float # Nuke damage (in % of enemy current hp)
var nuke_period: float # Period of time between 2 nukes

var healing_fire_area_activated: bool # True if the player has at least one of this card
var healing_fire_area_damage: float # Healing fire area damage (in % of enemies current hp)
var healing_fire_area_heal: float # Healing fire area heal (in % of allies current hp)
var healing_fire_area_range: int # Healing fire area range
var healing_fire_area_period: float # Time between 2 tick of damage/heal of the healing fire

var damage_increase_on_low_life_enemy_activated: bool # If this skill is activated
var damage_increase_on_low_life_enemy_percent: int # Damage increase on enemies below a threshold (in %)
var damage_increase_on_low_life_enemy_threshold: int # Threshold of the damage increase (in % of max hp)

var trail_damage : int # Fire trail damage (in % of enemy current hp)
var trail_life_time : float # Fire trial life time (in s)
var trail_period : float # Time between 2 tick of damage of fire trail
