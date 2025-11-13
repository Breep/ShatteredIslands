class_name FamilyLifeStats
extends FamilyStats

#region Common Cards
# [Proteins]
var proteins_activated: bool # If this skill is activated
var proteins_hp: int # Increase max HP by this number

# [Late Defender]
var late_defender_activated: bool # If this skill is activated
var late_defender_hp: int # max HP gained each tick
var late_defender_period: float # Period between each tick

# [Armor HP]
var armor_by_lost_hp_activated: bool # If this skill is activated
var armor_by_lost_hp_percent: float # Percent of hp lost converted into armor each tick
var armor_by_lost_hp_period: float # Period between each tick

# [The Collector]
var the_collector_activated: bool # If this skill is activated
var the_collector_hp: bool # max HP gained for each unique card

# [Dodge]
var dodge_activated: bool # If this skill is activated
var dodge_increase: float # Amount of dodge increase
var dodge_hp: int # max HP gained each dodge

# [Vicious Mockery]
var vicious_mockery_activated: bool # If this skill is activated
var vicious_mockery_life_time: float # Period of time all entities are taunt at start

# [Bear Strenght]
var bear_strenght_activated: bool # If skill is activated
var bear_strenght_speed_percent: float # % of AS decreased
var bear_strenght_ad_percent: float # % of max HP converted into AD
#endregion

#region Rare Cards
@export_group("RARE")
#endregion

#region Epic Cards
@export_group("EPIC")
#endregion

#region Legendary Cards
@export_group("LEGENDARY")
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
