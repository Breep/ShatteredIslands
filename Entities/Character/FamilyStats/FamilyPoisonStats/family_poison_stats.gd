class_name FamilyPoisonStats
extends FamilyStats

#region Common Cards
@export_group("COMMON")
@export_subgroup("Poison Flask")
@export var poison_flask_activated: bool # True if the player has at least one of this card
@export var poison_flask_stacks: int # Number of stack applied each tick
@export var poison_flask_period: float # Time between applying 2 stacks (in s)

@export_subgroup("Rusty Dagger")
@export var poison_rusty_dagger_activated: bool # True if the player has at least one of this card
@export var poison_rusty_dagger_stacks: int # Number of stack applied each proc
@export var poison_rusty_dagger_chance: float # % of chance to proc the skill

@export_subgroup("Rotting Milk")
@export var poison_rotting_milk_activated: bool # True if the player has at least one of this card
@export var poison_rotting_milk_regen_stacks: int # Number of regen stack applied each proc
@export var poison_rotting_milk_chance: float # % of chance to proc the skill

@export_subgroup("Hot Pot")
@export var poison_hot_pot_activated: bool # True if the player has at least one of this card
@export var poison_hot_pot_ignite_stacks: int # Number of ignite stack applied each proc
@export var poison_hot_pot_chance: float # % of chance to proc the skill

@export_subgroup("Antidote")
@export var poison_antidote_activated: bool # True if the player has at least one of this card
@export var poison_antidote_decrease: float # % of poison damage reduction

@export_subgroup("Venomous Darts")
@export var poison_venomous_darts_activated: bool # True if the player has at least one of this card
@export var poison_venomous_darts_period: float # Time between 2 darts throw
@export var poison_venomous_darts_darts_number: int # Number of darts thrown
@export var poison_venomous_darts_multiplier: float # damage multiplier <poison stacks> * multiplier
#endregion

#region Rare Cards
@export_group("RARE")
@export_subgroup("Contagion")
@export var poison_contagion_activated: bool # True if the player has at least one of this card
@export var poison_contagion_percent: float # % of stacks spread each death
@export var poison_contagion_radius: float # radius of the spread

@export_subgroup("Tide of Corruption")
@export var poison_tide_of_corruption_activated: bool # True if the player has at least one of this card
@export var poison_tide_of_corruption_period: float # Time between applying 2 ticks
@export var poison_tide_of_corruption_multiplier: float # damage multiplier <enemies alive> * multiplier

@export_subgroup("Corrosion")
@export var poison_corrosion_activated: bool # True if the player has at least one of this card
@export var poison_corrosion_buff_stacks: int # Number of buff stacks remove each time poison is applied
#endregion
 
#region Rare Cards
@export_group("EPIC")
@export_subgroup("Snake barrel")
@export var poison_snake_barrel_activated: bool # True if the player has at least one of this card
@export var poison_snake_barrel_hits_number: float # Number of hits before the barrel brakes
@export var poison_snake_barrel_snake_number: float # Number of snakes comming out of the barrel

@export_subgroup("Shrooms")
@export var poison_shrooms_activated: bool # True if the player has at least one of this card
@export var poison_shrooms_period: float # Time between to shrooms are spawned
@export var poison_shrooms_life_time: float # Time before the shroom explode
@export var poison_shrooms_damage: float # direct poison damage
@export var poison_shrooms_radius: float # radius of the explosion
#endregion

#region Legendary Cards
@export_group("LEGENDARY")
@export_subgroup("Death Smoke")
@export var poison_death_smoke_activated: bool # True if the player has at least one of this card
@export var poison_death_smoke_multiplier: float # Stack multiplier <seconds inside> * multiplier
@export var poison_death_smoke_period: float # Time between each tick
#endregion
