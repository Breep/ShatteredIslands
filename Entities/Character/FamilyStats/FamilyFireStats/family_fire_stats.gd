class_name FamilyFireStats
extends FamilyStats

#region Common Card
# [DARK FOREST]
var dark_forest_activated: bool
var dark_forest_increase_dodge: float
var dark_forest_ignite_stacks: float

# [EXPANSE UNIVERSE]
var expanse_universe_activated: bool
var expanse_universe_ignite_stacks: float
var expanse_universe_period: float

# [KUIPER BELT]
var kuiper_belt_activated: bool
var kuiper_belt_shield_amount: float
#endregion


#region Rare Card
# [COSMIC BOLT]
var cosmic_bolt_activated: bool
var cosmic_bolt_period: float
var cosmic_bolt_damage_per_stack: float # Multiplicateur de dégâts
var cosmic_bolt_bounce_chance_per_stack: float # Multiplicateur de chance

# [END OF THE WORLD]
var end_of_the_world_activated: bool # True if the player has at least one of this card
var end_of_the_world_stack_multiplier: float # Ignite stack multiplier to trigger the card
#endregion

#region Epic Card
# [NUKE]
var nuke_activated: bool # True if the player has at least one of this card
var nuke_ignite: float # ignite stack inflicted
#endregion

#region Legendary Card
#endregion


@export_group("Firebolt")
@export var firebolt_activated: bool # True if the player has at least one of this card
@export var firebolt_damage: float # Damage of the firebolt (in % of enemy current hp)
@export var firebolt_period: float # Period of time between 2 firebolts (in s)
