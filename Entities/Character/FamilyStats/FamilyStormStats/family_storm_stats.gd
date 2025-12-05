class_name FamilyStormStats
extends FamilyStats

#region Common Card
# [FARADAY]
var faraday_activated: bool
var faraday_crit_chance_boost: float

# [VIOLENT OVERLOAD]
var violent_overload_activated: bool
var violent_overload_crit_mult_boost: float

# [LIGHTNING FOOTWORK]
var lightning_footwork_activated: bool
var lightning_footwork_dodge_increase: float

# [QUICKCHARGE]
var quickcharge_activated: bool
var quickcharge_grind_percent: float

# [LIGHTNING ROD]
var lightning_rod_activated: bool
var lightning_rod_reduction: float
var lightning_rod_hp_threshold: float

# [EYE OF THE CYCLONE]
var eye_of_the_cyclone_activated: bool
var eye_of_the_cyclone_max_hp_percent: float

# [STORM BREAKER]
var storm_breaker_activated: bool
var storm_breaker_base_reduction_percent: float

# [STORM BATTERY]
var storm_battery_activated: bool
var storm_battery_mana_gain: float

#endregion

#region Rare Card
# [DYNAMO]
var dynamo_activated: bool
var dynamo_regen: float
var dynamo_shield: float
#endregion

#region Epic Card
# [THUNDER BERSERKER]
var thunder_berserker_activated: bool
var thunder_berserker_start_boost: float
var thunder_berserker_delay: float
var thunder_berserker_penalty_per_rank: float

# [CHAIN LIGHTNING]
var chain_lightning_activated: bool
var chain_lightning_dist_factor: float # Le pourcentage par unité de distance
var chain_lightning_chance_percent: float
#endregion

#region Legendary Card

# [THUNDER STORM]
var thunder_storm_activated: bool
var thunder_storm_duration_bonus: float

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
