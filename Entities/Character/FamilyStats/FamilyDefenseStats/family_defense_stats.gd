class_name FamilyDefenseStats
extends FamilyStats

#region Common Card

# [EVASIVE BARRIER]
var evasive_barrier_activated: bool
var evasive_barrier_dodge_increase: float
var evasive_barrier_shield_gain: float

# [FORCE FIELD]
var force_field_activated: bool
var force_field_period: float
var force_field_lost_hp_percent: float

# [MAGNETIC SIPHON]
var magnetic_siphon_activated: bool
var magnetic_siphon_period: float
var magnetic_siphon_steal_percent: float

# [ENERGY BARRIER]
var energy_barrier_activated: bool
var energy_barrier_shield_amount: float
var energy_barrier_period: float

# [SHIELD RUSH]
var shield_rush_activated: bool
var shield_rush_amount: float

# [REFLECTO BELT]
var reflecto_belt_activated: bool
var reflecto_belt_shield_threshold: float 
var reflecto_belt_attacks_count: int     
var reflecto_belt_damage_percent: float  

# [PROTECTIVE DOME]
var protective_dome_activated: bool
var protective_dome_armor_percent: float

# [AVENGERS ASSEMBLE]
var avengers_assemble_activated: bool
var avengers_assemble_crit_chance: float

#endregion

#region Rare Card


# [SHIELD THROW]
var shield_throw_activated: bool
var shield_throw_threshold: float
var shield_throw_damage: float
var shield_throw_return_shield: float

#endregion

#region Epic Card

# [AEGIS RESONATOR]
var aegis_resonator_activated: bool
var aegis_resonator_period: float
var aegis_resonator_total_shield: float

#endregion

#region Legendary Card
#endregion

@export_group("Dual Shield")
@export var dual_shield_activated: bool # True if this skill is activated
@export var dual_shield_health_threshold: int # % of hp minimum to trigger the dual shield effect

@export_group("Hedgehog Armor")
@export var hedgehog_armor_activated: bool # True if this skill is activated
@export var hedgehog_armor_period: float # Time between two ticks
@export var hedgehog_armor_lost_armor_percent: int # Percent of armor lost converted as damage

@export_group("Power Wrist")
@export var power_wrists_activated: bool # True if this skill is activated
@export var power_wrists_damage_increase_percent: int # % of damage increase for each power_wrist_armor_stacks
@export var power_wrists_armor_stacks: int # Armor stacks needed to increase damage by power_wrist_damage_increase_percent

@export_group("Rainbow Boot")
@export var rainbow_boots_activated: bool # True if this skill is activated
@export var rainbow_boots_armor_stacks: int # Armor stacks lost needed to proc rainbow_boots effect

@export_group("Smith Hammer")
@export var smith_hammer_activated: bool # True if this skill is activated
@export var smith_hammer_chance_percent: int # % of chance to proc effect when being hit
@export var smith_hammer_armor_stacks: int # Armor stacks gained when effect proc

@export_group("Gladiator Helmet")
@export var gladiator_helmet_activated: bool # True if this skill is activated
@export var gladiator_helmet_period: float # Time between 2 ticks
@export var gladiator_helmet_armor_stacks: int # Armor stacks gained every tick

@export_group("Adaptative Cloak")
@export var adaptative_cloak_activated: bool # True if this skill is activated
@export var adaptative_cloak_attack_percent: int # % Percent of AA damage converted into armor stacks


@export_group("Mystical Shoulders")
@export var mystical_shoulders_activated: bool # True if this skill is activated
@export var mystical_shoulders_magic_damage: int # Amount of magic damage needed to proc this skill
@export var mystical_shoulders_percent_inc: float # % of magic resist gained each time this skill proc
@export var mystical_shoulders_percent_max: float # Maximum % of magic resist
