class_name CharacterLifeStats
extends Resource

var increase_hp: int # Increase max character hp by this number

var damage_increased_by_hp_lost_activated: bool # If this skill is activated
var damage_increased_by_hp_lost_percentage: int # % of physical damage increased every damage_increase_by_hp_lost_hp_number
var damage_increased_by_hp_lost_hp_number: int # number of hp to lose to increase damage_increase_by_hp_lost_percentage

var damage_taken_reduced_below_treshold_activated:bool # If damage_taken_reduced_below_treshold is activated
var damage_taken_reduced_below_treshold_percentage: int # % of damage taken reduction
var damage_taken_reduced_below_treshold_threshold: int # threshold to activate damage_taken_reduced_below_treshold_percentage (in % of max hp)

var revive_after_death_triggered: bool # If the revive after death has been triggered
var revive_after_death_activated: bool # If revive after death is activated
var revive_after_death_percentage_life: int # % of max life after revival
var revive_after_death_percentage_damage: int # % of max life damage done to nearby enemies after revival
var revive_after_death_time: float # time to wait before revival (in s)

var poison_by_lost_hp_activated: bool # If this skill is activated
var poison_by_lost_hp_stacks: int # Number of poison stacks applied every tick
var poison_by_lost_hp_hp_number: int # Number of hp to lose to improve poison_by_lost_hp_stacks
var poison_by_lost_hp_period: float # Period of time between applying poison_by_lost_hp_stacks (in s)

var fire_damage_activated: bool # If this skill is activated
var fire_damage_period: float # Period of time between two fire_damage (in s)
var fire_damage_percent: float # % of enemy max life damage
