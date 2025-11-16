class_name FamilyDefenseStats
extends FamilyStats

#region Common Card
#endregion

#region Rare Card
#endregion

#region Epic Card
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

@export_group("Reflecto Belt")
@export var reflecto_belt_activated: bool # True if this skill is activated
@export var reflecto_belt_attack_increase_percent: int # % of damage increase for the next auto-attack
@export var reflecto_belt_armor_stacks: int # Armor stacks lost needed to proc reflecto_belt effect

@export_group("Smith Hammer")
@export var smith_hammer_activated: bool # True if this skill is activated
@export var smith_hammer_chance_percent: int # % of chance to proc effect when being hit
@export var smith_hammer_armor_stacks: int # Armor stacks gained when effect proc

@export_group("Gladiator Helmet")
@export var gladiator_helmet_activated: bool # True if this skill is activated
@export var gladiator_helmet_period: float # Time between 2 ticks
@export var gladiator_helmet_armor_stacks: int # Armor stacks gained every tick

@export_group("Titan Gloves")
@export var titan_gloves_activated: bool # True if this skill is activated
@export var titan_gloves_max_health_percent: bool # % of max life converted into armor stacks each tick
@export var titan_gloves_period: float # Time between 2 ticks

@export_group("Adaptative Cloak")
@export var adaptative_cloak_activated: bool # True if this skill is activated
@export var adaptative_cloak_attack_percent: int # % Percent of AA damage converted into armor stacks

@export_group("Evading Pants")
@export var evading_pants_activated: bool # True if this skill is activated
@export var evading_pants_armor_stacks: int # Armor stacks gained each dodge

@export_group("Mystical Shoulders")
@export var mystical_shoulders_activated: bool # True if this skill is activated
@export var mystical_shoulders_magic_damage: int # Amount of magic damage needed to proc this skill
@export var mystical_shoulders_percent_inc: float # % of magic resist gained each time this skill proc
@export var mystical_shoulders_percent_max: float # Maximum % of magic resist
