extends Resource
class_name CharacterDefenseStats

# Current armor on the character (like a shield, a second health bar)
# Decreases by taking damage: 1 damage = 1 armor stack consumed
var armor_stacks: int = 0

var dual_shield_activated: bool # True if this skill is activated
var dual_shield_health_threshold: int # % of hp minimum to trigger the dual shield effect

var hedgehog_armor_activated: bool # True if this skill is activated
var hedgehog_armor_period: float # Time between two ticks
var hedgehog_armor_lost_armor_percent: int # Percent of armor lost converted as damage

var power_wrists_activated: bool # True if this skill is activated
var power_wrists_damage_increase_percent: int # % of damage increase for each power_wrist_armor_stacks
var power_wrists_armor_stacks: int # Armor stacks needed to increase damage by power_wrist_damage_increase_percent

var rainbow_boots_activated: bool # True if this skill is activated
var rainbow_boots_armor_stacks: int # Armor stacks lost needed to proc rainbow_boots effect

var reflecto_belt_activated: bool # True if this skill is activated
var reflecto_belt_attack_increase_percent: int # % of damage increase for the next auto-attack
var reflecto_belt_armor_stacks: int # Armor stacks lost needed to proc reflecto_belt effect

var smith_hammer_activated: bool # True if this skill is activated
var smith_hammer_chance_percent: int # % of chance to proc effect when being hit
var smith_hammer_armor_stacks: int # Armor stacks gained when effect proc

var gladiator_helmet_activated: bool # True if this skill is activated
var gladiator_helmet_period: float # Time between 2 ticks
var gladiator_helmet_armor_stacks: int # Armor stacks gained every tick

var titan_gloves_activated: bool # True if this skill is activated
var titan_gloves_max_health_percent: bool # % of max life converted into armor stacks each tick
var titan_gloves_period: float # Time between 2 ticks

var adaptative_cloak_activated: bool # True if this skill is activated
var adaptative_cloak_attack_percent: int # % Percent of AA damage converted into armor stacks

var evading_pants_activated: bool # True if this skill is activated
var evading_pants_armor_stacks: int # Armor stacks gained each dodge

var mystical_shoulders_activated: bool # True if this skill is activated
var mystical_shoulders_magic_damage: int # Amount of magic damage needed to proc this skill
var mystical_shoulders_percent_inc: float # % of magic resist gained each time this skill proc
var mystical_shoulders_percent_max: float # Maximum % of magic resist
