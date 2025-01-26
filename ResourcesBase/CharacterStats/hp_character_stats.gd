class_name HpCharacterStats
extends Resource

@export var increase_hp: int # Increase max character hp by this number

@export var damage_increased_by_hp_lost_percentage: int # % of physical damage increased every damage_increase_by_hp_lost_hp_number
@export var damage_increased_by_hp_lost_hp_number: int # number of hp to lose to increase damage_increase_by_hp_lost_percentage

@export var damage_taken_reduced_below_treshold_percentage: int # % of damage taken reduction
@export var damage_taken_reduced_below_treshold_threshold: int # threshold to activate damage_taken_reduced_below_treshold_percentage (in % of max hp)

@export var revive_after_death: bool # If revive after death is activated
@export var revive_after_death_percentage_life: int # % of max life after revival
@export var revive_after_death_percentage_damage: int # % of max life damage done to nearby enemies after revival
@export var revive_after_death_time: float # time to wait before revival (in s)

@export var poison_by_lost_hp_stacks: int # Number of poison stacks applied every tick
@export var poison_by_lost_hp_hp_number: int # Number of hp to lose to improve poison_by_lost_hp_stacks
@export var poison_by_lost_hp_period: int # Period of time between applying poison_by_lost_hp_stacks

@export var hp_increased_on_move_hp: int # Number of hp increased every hp_increased_on_move_distance
@export var hp_increased_on_move_distance: int # Number of meters needed to activate hp_increased_on_move_hp
