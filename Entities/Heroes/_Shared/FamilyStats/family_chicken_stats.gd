class_name FamilyChickenLordStats
extends FamilyStats

enum CbVars {
	SELF_CHICKEN,
	ALIVE_CHICKENS,
	TOTAL_CHICKEN_NUMBER
}

var on_chicken_count_changed_callbacks: Array[Callable]
var on_ally_spawned_callbacks: Array[Callable]
var on_chicken_spawned_callbacks: Array[Callable]
var on_chicken_death_callbacks: Array[Callable]

var spawn_period_decrease: float
var gifted_chance_increase: float
var spawn_number_increase: int

var twins_chance: float
