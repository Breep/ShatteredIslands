class_name FamilyPoisonStats
extends FamilyStats

#region Common Cards
# [Poison FLask]
var poison_flask_activated: bool # True if the player has at least one of this card
var poison_flask_stacks: int # Number of stack applied each tick
var poison_flask_period: float # Time between applying 2 stacks (in s)

# [Rusty Dagger]
var poison_rusty_dagger_activated: bool # True if the player has at least one of this card
var poison_rusty_dagger_stacks: int # Number of stack applied each proc
var poison_rusty_dagger_chance: float # % of chance to proc the skill

# [Rotting Milk]
var poison_rotting_milk_activated: bool # True if the player has at least one of this card
var poison_rotting_milk_regen_stacks: int # Number of regen stack applied each proc
var poison_rotting_milk_chance: float # % of chance to proc the skill

# [Hot Pot]
var poison_hot_pot_activated: bool # True if the player has at least one of this card
var poison_hot_pot_ignite_stacks: int # Number of ignite stack applied each proc
var poison_hot_pot_chance: float # % of chance to proc the skill

# [Antidote]
var poison_antidote_activated: bool # True if the player has at least one of this card
var poison_antidote_decrease: float # % of poison damage reduction

# [Venomous Darts]
var poison_venomous_darts_activated: bool # True if the player has at least one of this card
var poison_venomous_darts_period: float # Time between 2 darts throw
var poison_venomous_darts_darts_number: int # Number of darts thrown
var poison_venomous_darts_multiplier: float # damage multiplier <poison stacks> * multiplier
#endregion

#region Rare Cards
# [Contagion]
var poison_contagion_activated: bool # True if the player has at least one of this card
var poison_contagion_percent: float # % of stacks spread each death
var poison_contagion_radius: float # radius of the spread

# [Tide of Corruption]
var poison_tide_of_corruption_activated: bool # True if the player has at least one of this card
var poison_tide_of_corruption_period: float # Time between applying 2 ticks
var poison_tide_of_corruption_multiplier: float # damage multiplier <enemies alive> * multiplier

# [Corrosion]
var poison_corrosion_activated: bool # True if the player has at least one of this card
var poison_corrosion_buff_stacks: int # Number of buff stacks remove each time poison is applied
#endregion
 
#region Epic Cards
# [Snake barrel]
var poison_snake_barrel_activated: bool # True if the player has at least one of this card
var poison_snake_barrel_health: float # Health of the barrel
var poison_snake_barrel_snake_number: float # Number of snakes comming out of the barrel
var poison_snake_barrel_snake_poison_stacks: float # Number of poison stacks carried by each snake

# [Shrooms]
var poison_shrooms_activated: bool # True if the player has at least one of this card
var poison_shrooms_period: float # Time between to shrooms are spawned
var poison_shrooms_life_time: float # Time before the shroom explode
var poison_shrooms_damage: float # direct poison damage
var poison_shrooms_radius: float # radius of the explosion
#endregion

#region Legendary Cards
# [Death Smoke]
var poison_death_smoke_activated: bool # True if the player has at least one of this card
var poison_death_smoke_multiplier: float # Stack multiplier <seconds inside> * multiplier
var poison_death_smoke_period: float # Time between each tick
#endregion
