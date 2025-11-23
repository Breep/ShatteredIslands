class_name FamilyStormStats
extends FamilyStats

#region Common Card

# [STORM BREAKER]
var storm_breaker_activated: bool
var storm_breaker_base_reduction_percent: float 

#endregion

#region Rare Card

#endregion

#region Epic Card

#endregion

#region Legendary Card
#endregion

var periodic_vulnerability_activated: bool # True if the player has at least one of this card
var periodic_vulnerability_amount: int # amount of vulnerability stack inflicted every period
var periodic_vulnerability_period: float # Time between to applying of vulnerability stacks (in s)

var crit_heal_activated: bool # If this skill is activated
var crit_heal_amount: int # % of critical damage converted into heal

var crit_vulnerability_activated: bool # If this skill is activated
var crit_vulnerability_amount: int # amount of vulnerability stack inflicted for each critical strike

var focused: bool # If the skill is triggered (AttackManager set this, StormManager read this)
var focus_target_activated: bool # If this skill is activated
var focus_target_time_before: float # time needed targeting the same target before activationg focus (in s)
var focus_target_crit_min: float # min value of crit bonus
var focus_target_crit_max: float # max value of crit bonus
var focus_target_crit_current: float # current value of crit bonus
var focus_target_duration: float # time needed to go from min to max bonus value (in s)

var overcharge_activated: bool # if overcharge is activated or not
var overcharge_percent: float # % of damage transmited

var lost_hp_crit_multiplier_activated: bool # If this skill is activated
var lost_hp_crit_multiplier_amount: int # % of crit damage increase
var lost_hp_crit_multiplier_hp_number: int # Number of hp needed to increase crit by lost_hp_crit_multiplier_amount

var crit_poison_activated: bool # If this skill is activated
var crit_poison_amount: int # % of critical damage converted into poison

var speed_boosted: bool # If the skill is triggered (StormManager set this, MovementManager read this)
var crit_move_speed_activated: bool # If this skill is activated
var crit_move_speed_amount: int # % of move speed increase after for each critical strike
var crit_move_speed_duration: float # Duration of the move speed increase (in s)
