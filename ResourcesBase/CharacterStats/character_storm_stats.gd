class_name CharacterStormStats
extends Resource

# Current vulnerability stacks on the hero (increase ALL attacker crit chance on character)
# Decreases by 10% each second with a minimum of 10 stacks
var vulnerability_stacks: int = 0

var periodic_vulnerability_activated: bool # True if the player has at least one of this card
var periodic_vulnerability_amount: int # amount of vulnerability stack inflicted every period
var periodic_vulnerability_period: float # Time between to applying of vulnerability stacks (in s)

var healing_crit_amount: int # % of critical damage converted into heal

var crit_vulnerability_amount: int # amount of vulnerability stack inflicted for each critical strike

var focus_target_time_before: int # time needed targeting the same target before activationg focus (in sec)
var focus_target_crit_min: float # min value of crit bonus
var focus_target_crit_max: float # max value of crit bonus
var focus_target_duration: int # time needed to go from min to max bonus value (in sec)

var overcharge_activated: bool # if overcharge is activated or not
var overcharge_percent: bool # % of damage transmited

var lost_hp_crit_multiplier_amount: int # % of crit damage increase
var lost_hp_crit_multiplier_hp_number: int # Number of hp needed to increase crit by lost_hp_crit_multiplier_amount

var crit_poison_amount: int # % of critical damage converted into poison

var crit_move_speed_amount: int # % of move speed increase after for each critical strike
var crit_move_speed_duration: float # Duration of the move speed increase (in s)


func get_vulnerability_critical_multiplier() -> float:
	return vulnerability_stacks / 10.0
