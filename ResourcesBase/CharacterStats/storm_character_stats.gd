class_name StormCharacterStats
extends Resource

@export var periodic_vulnerability_amount: int # amount of vulnerability stack inflicted every period
@export var periodic_vulnerability_period: int # Time between to applying of vulnerability stacks (in s)

@export var healing_crit_amount: int # % of critical damage converted into heal

@export var crit_vulnerability_amount: int # amount of vulnerability stack inflicted for each critical strike

@export var focus_target_time_before: int # time needed targeting the same target before activationg focus (in sec)
@export var focus_target_crit_min: float # min value of crit bonus
@export var focus_target_crit_max: float # max value of crit bonus
@export var focus_target_duration: int # time needed to go from min to max bonus value (in sec)

@export var overcharge_activated: bool # if overcharge is activated or not
@export var overcharge_percent: bool # % of damage transmited

@export var lost_hp_crit_multiplier_amount: int # % of crit damage increase
@export var lost_hp_crit_multiplier_hp_number: int # Number of hp needed to increase crit by lost_hp_crit_multiplier_amount

@export var crit_poison_amount: int # % of critical damage converted into poison

@export var crit_move_speed_amount: int # % of move speed increase after for each critical strike
@export var crit_move_speed_duration: float # Duration of the move speed increase (in s)
