class_name FamilyLifeStats
extends FamilyStats

#region Common Cards

# [PROTEINS]
var proteins_activated: bool
var proteins_max_hp_increase: float

# [EVASIVE GROWTH]
var evasive_growth_activated: bool
var evasive_growth_increase_dodge: float
var evasive_growth_increase_max_hp: float

# [TITAN'S PROTECTION]
var titans_protection_activated: bool
var titans_protection_period: float
var titans_protection_lost_hp_percent: float

# [BEAR STRENGTH]
var bear_strength_activated: bool
var bear_strength_as_reduction: float # La réduction d'AS (ex: 7.0)
var bear_strength_hp_to_ad_percent: float # Le % de conversion (ex: 1.5)

# [ANCIENT GROWTH]
var ancient_growth_activated: bool
var ancient_growth_period: float
var ancient_growth_amount: float

# [THE ANCIENT COLLECTOR]
var ancient_collector_activated: bool
var ancient_collector_amount_per_card: float

#endregion

#region Rare Cards

# [TAINTED BLOOD]
var tainted_blood_activated: bool
var tainted_blood_period: float
var tainted_blood_lost_hp_percent: float

# [CRYSTAL MOUNTAIN]
var crystal_mountain_activated: bool
var crystal_mountain_defense_increase: float

#endregion

#region Epic Cards

# [VITAL PULSE]
var vital_pulse_activated: bool
var vital_pulse_period: float
var vital_pulse_damage_percent: float

#endregion

#region Legendary Cards
#endregion

var damage_increased_by_hp_lost_activated: bool # If this skill is activated
var damage_increased_by_hp_lost_percentage: int # % of physical damage increased every damage_increase_by_hp_lost_hp_number
var damage_increased_by_hp_lost_hp_number: int # number of hp to lose to increase damage_increase_by_hp_lost_percentage


var damage_taken_reduced_below_treshold_activated: bool # If damage_taken_reduced_below_treshold is activated
var damage_taken_reduced_below_treshold_percentage: int # % of damage taken reduction
var damage_taken_reduced_below_treshold_threshold: int # threshold to activate damage_taken_reduced_below_treshold_percentage (in % of max hp)

var revive_after_death_triggered: bool # If the revive after death has been triggered
var revive_after_death_activated: bool # If revive after death is activated
var revive_after_death_percentage_life: int # % of max life after revival
var revive_after_death_percentage_damage: int # % of max life damage done to nearby enemies after revival
var revive_after_death_time: float # time to wait before revival (in s)


var fire_damage_activated: bool # If this skill is activated
var fire_damage_period: float # Period of time between two fire_damage (in s)
var fire_damage_percent: float # % of enemy max life damage
